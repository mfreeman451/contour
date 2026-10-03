defmodule Contour.Runtime do
  @moduledoc "Runtime roles and placement. Web nodes never supervise match processes."

  def role, do: Application.fetch_env!(:contour, :role)
  def core?, do: role() in [:core, :all]
  def web?, do: role() in [:web, :all]
  def clustered?, do: Application.get_env(:contour, :cluster_enabled, false)

  def children do
    if clustered?() do
      crdt = Application.fetch_env!(:contour, :horde_crdt)

      [
        %{id: :contour_roles, start: {:pg, :start_link, [:contour_roles]}},
        {Horde.Registry,
         name: Contour.MatchRegistry, keys: :unique, members: :auto, delta_crdt_options: crdt}
      ] ++
        core_children(crdt) ++ [Contour.Cluster.Membership]
    else
      [{Registry, keys: :unique, name: Contour.MatchRegistry}] ++
        if(core?(),
          do: [{DynamicSupervisor, strategy: :one_for_one, name: Contour.MatchSupervisor}],
          else: []
        )
    end
  end

  defp core_children(crdt) do
    if core?() do
      [
        {Horde.DynamicSupervisor,
         name: Contour.MatchSupervisor,
         strategy: :one_for_one,
         members: [{Contour.MatchSupervisor, node()}],
         process_redistribution: :passive,
         delta_crdt_options: crdt}
      ]
    else
      []
    end
  end

  def via(id), do: {:via, registry_module(), {Contour.MatchRegistry, id}}

  def lookup(id), do: registry_module().lookup(Contour.MatchRegistry, id)

  def start_match(child_spec) do
    cond do
      not core?() -> {:error, :core_role_required}
      clustered?() -> Horde.DynamicSupervisor.start_child(Contour.MatchSupervisor, child_spec)
      true -> DynamicSupervisor.start_child(Contour.MatchSupervisor, child_spec)
    end
  end

  defp registry_module, do: if(clustered?(), do: Horde.Registry, else: Registry)
end
