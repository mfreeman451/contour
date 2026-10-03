defmodule Contour.ClusterFixture do
  # A peer RPC is short-lived. The real supervision tree must survive its caller.
  def start(children) do
    {:ok, supervisor} =
      Supervisor.start_link(children, strategy: :one_for_one, name: Contour.SmokeSupervisor)

    Process.unlink(supervisor)
    :ok
  end
end
