use Mix.Config

if System.get_env("CI") == "true" do
  config :logger, backends: [Action.LoggerBackend]
end

# config :logger, Action.LoggerBackend, metadata: [:mfa]

config :tentacat, :extra_headers, [
  {"Accept", "application/vnd.github.squirrel-girl-preview+json"}
]
