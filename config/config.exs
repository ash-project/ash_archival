import Config

if Mix.env() == :test do
  config :ash_storage, ash_domains: [AshStorage.Test.Domain]

  config :ash_storage,
    ecto_repos: [AshStorage.TestRepo]

  config :ash, :validate_domain_resource_inclusion?, false
  config :ash, :validate_domain_config_inclusion?, false
  config :logger, level: :warning

  config :ash_storage, AshStorage.TestRepo,
    username: "postgres",
    password: "postgres",
    database: "ash_storage_test",
    hostname: "localhost",
    pool: Ecto.Adapters.SQL.Sandbox
end

if Mix.env() == :dev do
  config :git_ops,
    mix_project: AshStorage.MixProject,
    changelog_file: "CHANGELOG.md",
    repository_url: "https://github.com/ash-project/ash_storage",
    # Instructs the tool to manage your mix version in your `mix.exs` file
    # See below for more information
    manage_mix_version?: true,
    # Instructs the tool to manage the version in your README.md
    # Pass in `true` to use `"README.md"` or a string to customize
    manage_readme_version: [
      "README.md",
      "documentation/tutorials/get-started-with-ash-storage.md"
    ],
    version_tag_prefix: "v"
end
