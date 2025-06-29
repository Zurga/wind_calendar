defmodule WeatherCalendar.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application
  use Boundary, top_level?: true, deps: [WeatherCalendar, WeatherCalendarWeb]

  @impl true
  def start(_type, _args) do
    children = [
      WeatherCalendarWeb.Telemetry,
      # WeatherCalendar.Repo,
      {DNSCluster, query: Application.get_env(:weather_calendar, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: WeatherCalendar.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: WeatherCalendar.Finch},
      # {EctoSync, repo: WeatherCalendar.Repo, cache_name: :live_cache, watchers: []},
      TzWorld.Backend.EtsWithIndexCache,
      # Start a worker by calling: WeatherCalendar.Worker.start_link(arg)
      # {WeatherCalendar.Worker, arg},
      # Start to serve requests, typically the last entry
      WeatherCalendarWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WeatherCalendar.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    WeatherCalendarWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
