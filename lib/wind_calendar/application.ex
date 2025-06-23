defmodule WindCalendar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  use Boundary, top_level?: true, deps: [WindCalendar, WindCalendarWeb]

  @impl true
  def start(_type, _args) do
    children = [
      WindCalendarWeb.Telemetry,
      # WindCalendar.Repo,
      {DNSCluster, query: Application.get_env(:wind_calendar, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WindCalendar.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WindCalendar.Finch},
      {EctoSync, repo: WindCalendar.Repo, cache_name: :live_cache, watchers: []},
      TzWorld.Backend.EtsWithIndexCache,
      # Start a worker by calling: WindCalendar.Worker.start_link(arg)
      # {WindCalendar.Worker, arg},
      # Start to serve requests, typically the last entry
      WindCalendarWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WindCalendar.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WindCalendarWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
