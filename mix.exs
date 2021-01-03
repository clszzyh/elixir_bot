defmodule ElixirBot.MixProject do
  use Mix.Project

  @version String.trim(File.read!("VERSION"))
  @github_url "https://github.com/clszzyh/elixir_bot"
  @description String.trim(Enum.at(String.split(File.read!("README.md"), "<!-- MDOC -->"), 1, ""))

  def project do
    [
      app: :elixir_bot,
      version: @version,
      description: @description,
      elixir: "~> 1.11",
      start_permanent: Mix.env() == :prod,
      preferred_cli_env: [ci: :test],
      elixirc_options: [warnings_as_errors: System.get_env("CI") == "true"],
      deps: deps(),
      dialyzer: [
        plt_core_path: "priv/plts",
        plt_add_deps: :transitive,
        plt_add_apps: [:ex_unit],
        list_unused_filters: true,
        plt_file: {:no_warn, "priv/plts/dialyzer.plt"},
        flags: dialyzer_flags()
      ],
      docs: [
        source_ref: "v" <> @version,
        source_url: @github_url,
        main: "readme",
        extras: ["README.md", "CHANGELOG.md"]
      ],
      aliases: aliases()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp dialyzer_flags do
    [
      :error_handling,
      :race_conditions,
      # :underspecs,
      :unknown,
      :unmatched_returns
      # :overspecs
      # :specdiffs
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:tentacat, "~> 2.0"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", runtime: false}
    ]
  end

  defp aliases do
    [
      ci: [
        "compile --warnings-as-errors --force --verbose",
        "format --check-formatted",
        "credo --strict",
        "docs",
        "dialyzer",
        "test"
      ]
    ]
  end
end
