defmodule AshStorage.MixProject do
  use Mix.Project

  @version "1.1.1"
  @description """
  An Ash extension to implement storage for resources.
  """

  def project do
    [
      app: :ash_storage,
      version: @version,
      elixir: "~> 1.13",
      source_url: "https://github.com/ash-project/ash_storage",
      homepage_url: "https://github.com/ash-project/ash_storage",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      description: @description,
      aliases: aliases(),
      package: package(),
      deps: deps(),
      docs: &docs/0,
      consolidate_protocols: Mix.env() != :test
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp package do
    [
      name: :ash_storage,
      licenses: ["MIT"],
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*
      CHANGELOG* documentation),
      links: %{
        GitHub: "https://github.com/ash-project/ash_storage"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}",
      extras: [
        {"README.md", title: "Home"},
        "documentation/tutorials/get-started-with-ash-storage.md",
        "documentation/topics/unstorage.md",
        "documentation/topics/how-does-ash-storage-work.md",
        "documentation/topics/upserts-and-identities.md",
        {"documentation/dsls/DSL-AshStorage.Resource.md",
         search_data: Spark.Docs.search_data_for(AshStorage.Resource)},
        "CHANGELOG.md"
      ],
      groups_for_extras: [
        Tutorials: ~r'documentation/tutorials',
        "How To": ~r'documentation/how_to',
        Topics: ~r'documentation/topics',
        DSLs: ~r'documentation/dsls'
      ],
      before_closing_head_tag: fn type ->
        if type == :html do
          """
          <script>
            if (location.hostname === "hexdocs.pm") {
              var script = document.createElement("script");
              script.src = "https://plausible.io/js/script.js";
              script.setAttribute("defer", "defer")
              script.setAttribute("data-domain", "ashhexdocs")
              document.head.appendChild(script);
            }
          </script>
          """
        end
      end,
      groups_for_modules: [
        Extension: [
          AshStorage,
          AshStorage.Resource
        ],
        Introspection: [
          AshStorage.Resource.Info
        ]
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ash, ash_version("~> 3.0 and >= 3.0.5")},
      # dev/test dependencies
      {:ash_postgres, "~> 2.3", only: [:dev, :test]},
      {:simple_sat, "~> 0.1.0", only: [:dev, :test]},
      {:git_ops, "~> 2.5", only: [:dev, :test]},
      {:ex_doc, "~> 0.37-rc", only: [:dev, :test], runtime: false},
      {:ex_check, "~> 0.14", only: [:dev, :test]},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:sobelow, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:mix_audit, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:igniter, "~> 0.5", only: [:dev, :test]}
    ]
  end

  defp aliases do
    [
      sobelow:
        "sobelow --skip -i Config.Secrets --ignore-files lib/migration_generator/migration_generator.ex",
      docs: [
        "spark.cheat_sheets",
        "docs",
        "spark.replace_doc_links"
      ],
      "test.create": "ash_postgres.create",
      "test.migrate": "ash_postgres.migrate",
      credo: "credo --strict",
      "spark.formatter": "spark.formatter --extensions AshStorage.Resource",
      "spark.cheat_sheets": "spark.cheat_sheets --extensions AshStorage.Resource"
    ]
  end

  defp ash_version(default_version) do
    case System.get_env("ASH_VERSION") do
      nil -> default_version
      "local" -> [path: "../ash", override: true]
      "main" -> [git: "https://github.com/ash-project/ash.git", override: true]
      version -> "~> #{version}"
    end
  end
end
