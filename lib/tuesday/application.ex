defmodule Tuesday.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      TuesdayWeb.Telemetry,
      Tuesday.Repo,
      {DNSCluster, query: Application.get_env(:tuesday, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Tuesday.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Tuesday.Finch},
      # Start a worker by calling: Tuesday.Worker.start_link(arg)
      # {Tuesday.Worker, arg},
      # Start to serve requests, typically the last entry
      TuesdayWeb.Endpoint,
      Tuesday.ProjectViewHistory
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Tuesday.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    TuesdayWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
