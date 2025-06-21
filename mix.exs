defmodule WindCalendar.MixProject do
  use Mix.Project

  @test_envs ~w/test integration_test/a

  def project do
    [
      app: :wind_calendar,
      version: "0.1.0",
      elixir: "~> 1.14",
      elixirc_paths: elixirc_paths(Mix.env()),
      test_paths: test_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps(),
      compilers: Mix.compilers() ++ [:surface, :boundary]
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {WindCalendar.Application, []},
      extra_applications: [:logger, :runtime_tools]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:integration_test), do: ["lib", "test/support"]
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(:dev), do: ["lib"] ++ catalogues()
  defp elixirc_paths(_), do: ["lib"]

  defp test_paths(:integration_test) do
    ["integration_test"]
  end

  defp test_paths(_) do
    ["test"]
  end

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "1.7.18"},
      {:phoenix_ecto, "~> 4.4"},
      {:ecto_sql, "~> 3.10"},
      {:ecto_sync, "~> 0.1.0"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 4.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_view, "~> 1.0.0", override: true},
      {:floki, ">= 0.30.0", only: :test},
      {:phoenix_live_dashboard, "~> 0.8.3"},
      {:esbuild, "~> 0.8", runtime: Mix.env() == :dev},
      {:swoosh, "~> 1.5"},
      {:finch, "~> 0.13"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 1.0"},
      {:gettext, "~> 0.20"},
      {:jason, "~> 1.2"},
      {:dns_cluster, "~> 0.1.1"},
      {:bandit, "~> 1.5"},
      {:surface, "~> 0.12.0"},
      {:surface_form_helpers, "~> 0.2.0"},
      {:surface_catalogue, "~> 0.6.2"},
      {:punkix, github: "Zurga/punkix"},
      {:boundary, "~> 0.10.0"},
      {:typed_ecto_schema, "~> 0.4.1"},
      {:flop, "~> 0.25.0"},
      {:deps_nix, "~> 2.0", only: :dev},
      {:magical, "~> 1.0.1"},
      {:error_tracker, "~> 0.6.0"},
      {:tz_world, "~> 1.3"},

      # Testing deps
      {:skipper, "~> 0.3.0", only: @test_envs},
      {:wallaby, github: "Zurga/wallaby", only: @test_envs},
      {:credo, "~> 1.7", only: [:dev | @test_envs]}
    ]
  end

  def catalogues do
    [
      # Local catalogue
      "priv/catalogue",
      # Dependencies catalogues
      "deps/surface/priv/catalogue"
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup", "assets.setup", "assets.build"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      integration_test: &run_integration_tests/1,
      "test.all": ["test", "integration_test"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.setup": ["esbuild.install --if-missing"],
      "assets.build": ["esbuild wind_calendar"],
      "assets.deploy": [
        "esbuild wind_calendar --minify",
        "phx.digest"
      ],
      "deps.get": ["deps.get", "deps.nix"],
      "deps.update": ["deps.update", "deps.nix"]
    ]
  end

  defp run_integration_tests(args) do
    env = "integration_test"
    args = if(IO.ANSI.enabled?(), do: ["--color" | args], else: ["--no-color" | args])
    IO.puts("==> Running tests with MIX_ENV=#{env}")

    (~w/compile assets.build/ ++ [["test" | args]])
    |> Enum.reduce_while(0, fn command, res ->
      if res > 0 do
        {:halt, System.at_exit(fn _ -> exit({:shutdown, 1}) end)}
      else
        {_, res} =
          System.cmd("mix", List.flatten([command]),
            into: IO.binstream(:stdio, :line),
            env: [{"MIX_ENV", env}]
          )

        {:cont, res}
      end
    end)
  end
end
