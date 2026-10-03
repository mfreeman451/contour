defmodule Contour.Cluster.Membership do
  @moduledoc "Advertises core participation through pg and updates Horde placement membership."
  use GenServer

  def start_link(opts), do: GenServer.start_link(__MODULE__, opts, name: __MODULE__)

  @impl true
  def init(_opts) do
    if Contour.Runtime.core?(), do: :pg.join(:contour_roles, :core, self())
    send(self(), :sync)
    {:ok, []}
  end

  @impl true
  def handle_info(:sync, previous) do
    members =
      :pg.get_members(:contour_roles, :core)
      |> Enum.map(&{Contour.MatchSupervisor, node(&1)})
      |> Enum.uniq()
      |> Enum.sort()

    if Contour.Runtime.core?() and members != previous do
      :ok = Horde.Cluster.set_members(Contour.MatchSupervisor, members)
      :telemetry.execute([:contour, :cluster, :membership], %{count: length(members)}, %{})
    end

    Process.send_after(self(), :sync, Application.fetch_env!(:contour, :membership_interval))
    {:noreply, members}
  end
end
