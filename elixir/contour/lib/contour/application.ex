defmodule Contour.Application do
  use Application

  @impl true
  def start(_type, _args) do
    children =
      [ContourWeb.Telemetry, Contour.Repo, {Phoenix.PubSub, name: Contour.PubSub}] ++
        cluster_children() ++ Contour.Runtime.children() ++ core_children() ++ web_children()

    Supervisor.start_link(children, strategy: :one_for_one, name: Contour.Supervisor)
  end

  defp cluster_children do
    if Contour.Runtime.clustered?() do
      [
        {Cluster.Supervisor,
         [Application.fetch_env!(:libcluster, :topologies), [name: Contour.ClusterSupervisor]]}
      ]
    else
      []
    end
  end

  defp core_children do
    if Contour.Runtime.core?() do
      [
        {Oban,
         AshOban.config(
           Application.fetch_env!(:contour, :ash_domains),
           Application.fetch_env!(:contour, Oban)
         )}
      ] ++
        case Application.get_env(:contour, :health_port) do
          nil -> []
          port -> [{Bandit, plug: ContourWeb.Health, port: port, ip: {0, 0, 0, 0}}]
        end
    else
      []
    end
  end

  defp web_children do
    if Contour.Runtime.web?() do
      oidc =
        if Application.get_env(:contour, :oidc) do
          [
            {Oidcc.ProviderConfiguration.Worker,
             %{
               issuer: "https://accounts.google.com",
               name: Contour.OIDCProvider,
               provider_configuration_opts: %{request_opts: Contour.Auth.OIDC.request_opts()}
             }}
          ]
        else
          []
        end

      oidc ++ [ContourWeb.Endpoint]
    else
      []
    end
  end

  @impl true
  def config_change(changed, _new, removed) do
    if Contour.Runtime.web?(), do: ContourWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
