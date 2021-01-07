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
      package: [
        licenses: ["MIT"],
        files: ["lib", ".formatter.exs", "mix.exs", "README*", "CHANGELOG*", "VERSION"],
        exclude_patterns: ["priv/plts", ".DS_Store"],
        links: %{"GitHub" => @github_url, "Changelog" => @github_url <> "/blob/main/CHANGELOG.md"}
      ],
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
      escript: [main_module: ElixirBot],
      deps: deps(),
      releases: releases(),
      aliases: aliases()
    ]
  end

  defp releases do
    [
      elixir_bot: [
        include_executables_for: [:unix],
        steps: [:assemble, &copy_extra_files/1],
        applications: [runtime_tools: :permanent]
      ]
    ]
  end

  defp copy_extra_files(release) do
    File.cp!(".iex.exs", Path.join(release.path, ".iex.exs"))
    release
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
      {:earmark, "~> 1.4"},
      # {:action, "~> 0.1"},
      {:action, github: "clszzyh/action"},
      # {:action, path: "../action"},
      {:dialyxir, "~> 1.0", only: [:dev, :test], runtime: false},
      {:credo, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_doc, "~> 0.22", runtime: false}
    ]
  end

  defp aliases do
    [
      docker_build: "cmd docker build -t elixir_bot:latest .",
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
