use Mix.Config

config :logger, backends: [Action.LoggerBackend]

config :tentacat, :extra_headers, [{"Accept", "application/vnd.github.black-cat-preview+json"}]
