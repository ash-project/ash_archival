import Config

if Mix.env() == :test do
  config :ash_archival, ash_domains: [AshArchival.Test.Domain]

  config :ash_archival,
    ecto_repos: [AshArchival.TestRepo]

  config :ash, :validate_domain_resource_inclusion?, false
  config :ash, :validate_domain_config_inclusion?, false
  config :logger, level: :warning

  config :ash_archival, AshArchival.TestRepo,
    username: "postgres",
    database: "ash_archival_test",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox
end

if Mix.env() == :dev do
  config :git_ops,
    mix_project: AshArchival.MixProject,
    changelog_file: "CHANGELOG.md",
    repository_url: "https://github.com/ash-project/ash_archival",
    # Instructs the tool to manage your mix version in your `mix.exs` file
    # See below for more information
    manage_mix_version?: true,
    # Instructs the tool to manage the version in your README.md
    # Pass in `true` to use `"README.md"` or a string to customize
    manage_readme_version: [
      "README.md",
      "documentation/tutorials/get-started-with-ash-archival.md"
    ],
    version_tag_prefix: "v"
end
