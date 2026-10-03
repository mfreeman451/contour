ExUnit.start()

defmodule Contour.ClusterSmokeTest do
  use ExUnit.Case
  @moduletag timeout: 90_000

  test "TLS-distributed web/core nodes discover, enforce placement, scale, and remove lost members" do
    stamp = :crypto.strong_rand_bytes(8) |> Base.encode16(case: :lower)
    {:ok, _} = Node.start(String.to_atom("contour_control_#{stamp}@127.0.0.1"), :longnames)
    Node.set_cookie(String.to_atom("contour_smoke_#{stamp}"))

    specs =
      for role <- [:web, :core], index <- 1..3, do: {role, "contour_#{role}_#{stamp}_#{index}"}

    extra = {:core, "contour_core_#{stamp}_4"}
    nodes = Enum.map(specs ++ [extra], fn {_, name} -> String.to_atom(name <> "@127.0.0.1") end)
    Process.put(:smoke_peers, [])

    try do
      peers = Enum.map(specs, &start_peer(&1, nodes))
      cores = for {:core, _, node} <- peers, do: node
      webs = for {:web, _, node} <- peers, do: node
      assert eventually(fn -> Enum.all?(cores, &(members(&1) == Enum.sort(cores))) end)

      via = :erpc.call(hd(cores), Contour.Runtime, :via, [:placement_probe])

      child = %{
        id: :placement_probe,
        start: {:gen_event, :start_link, [via]},
        restart: :temporary
      }

      assert {:ok, pid} = :erpc.call(hd(cores), Contour.Runtime, :start_match, [child])
      assert node(pid) in cores

      assert eventually(fn ->
               Enum.all?(webs, fn web ->
                 :erpc.call(web, Contour.Runtime, :lookup, [:placement_probe]) == [{pid, nil}]
               end)
             end)

      for web <- webs do
        assert :erpc.call(web, Process, :whereis, [Contour.MatchSupervisor]) == nil

        assert :erpc.call(web, Contour.Runtime, :start_match, [child]) ==
                 {:error, :core_role_required}

        assert :erpc.call(web, :gen_event, :which_handlers, [pid]) == []
      end

      {:core, _, added_node} = start_peer(extra, nodes)
      all_cores = Enum.sort([added_node | cores])
      assert eventually(fn -> Enum.all?(all_cores, &(members(&1) == all_cores)) end)

      {_, owner_peer, _} = Enum.find(peers, fn {_, _, node} -> node == node(pid) end)
      :ok = :peer.stop(owner_peer)
      remaining = List.delete(all_cores, node(pid))
      assert eventually(fn -> Enum.all?(remaining, &(members(&1) == remaining)) end)

      # Horde relocates children after node loss, even for a temporary child.
      # Game lifecycle leases must fence this relocation before hosting real matches.
      assert eventually(fn ->
               case :erpc.call(hd(webs), Contour.Runtime, :lookup, [:placement_probe]) do
                 [{replacement, nil}] when replacement != pid ->
                   node(replacement) in remaining and
                     :erpc.call(node(replacement), Process, :alive?, [replacement]) and
                     Enum.all?(webs, fn web ->
                       :erpc.call(web, Contour.Runtime, :lookup, [:placement_probe]) ==
                         [{replacement, nil}]
                     end)

                 _ ->
                   false
               end
             end)
    after
      for {_, peer, _} <- Process.get(:smoke_peers), Process.alive?(peer), do: :peer.stop(peer)
    end
  end

  defp start_peer({role, name}, nodes) do
    paths = Enum.flat_map(:code.get_path(), &[~c"-pa", &1])

    args =
      [
        ~c"+S",
        ~c"2:2",
        ~c"-kernel",
        ~c"prevent_overlapping_partitions",
        ~c"false",
        ~c"-setcookie",
        Atom.to_charlist(Node.get_cookie()),
        ~c"-proto_dist",
        ~c"inet_tls",
        ~c"-ssl_dist_optfile",
        String.to_charlist(System.fetch_env!("CLUSTER_SMOKE_TLS_FILE"))
      ] ++ paths

    {:ok, peer, node} =
      :peer.start_link(%{
        name: String.to_charlist(name),
        host: ~c"127.0.0.1",
        longnames: true,
        connection: :standard_io,
        args: args,
        env: [{~c"ERL_FLAGS", ~c""}]
      })

    Process.put(:smoke_peers, [{role, peer, node} | Process.get(:smoke_peers)])
    :erpc.call(node, Application, :ensure_all_started, [:horde])
    :erpc.call(node, Application, :ensure_all_started, [:libcluster])

    :erpc.call(node, Application, :put_all_env, [
      [
        contour: [
          role: role,
          cluster_enabled: true,
          membership_interval: 100,
          horde_crdt: [sync_interval: 100, max_sync_size: 200]
        ]
      ]
    ])

    topology = [
      smoke: [strategy: Cluster.Strategy.Epmd, config: [hosts: nodes, polling_interval: 100]]
    ]

    children =
      [{Cluster.Supervisor, [topology, [name: Contour.ClusterSupervisor]]}] ++
        :erpc.call(node, Contour.Runtime, :children, [])

    :ok = :erpc.call(node, Contour.ClusterFixture, :start, [children])
    {role, peer, node}
  end

  defp members(node),
    do:
      :erpc.call(node, Horde.Cluster, :members, [Contour.MatchSupervisor])
      |> Enum.map(&elem(&1, 1))
      |> Enum.sort()

  defp eventually(fun, attempts \\ 100)
  defp eventually(_fun, 0), do: false

  defp eventually(fun, attempts) do
    if fun.(),
      do: true,
      else:
        (
          Process.sleep(100)
          eventually(fun, attempts - 1)
        )
  end
end
