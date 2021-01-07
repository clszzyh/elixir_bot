use Mix.Config

config :logger, backends: [Action.LoggerBackend]

config :logger, Action.LoggerBackend, metadata: [:mfa]

config :tentacat, :extra_headers, [
  {"Accept", "application/vnd.github.squirrel-girl-preview+json"}
]
