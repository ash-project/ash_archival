defmodule AshArchival.MixProject do
  use Mix.Project

  @version "0.1.5"
  @description """
  A small resource extension that sets a resource up to archive instead of destroy.
  """

  def project do
    [
      app: :ash_archival,
      version: @version,
      elixir: "~> 1.13",
      source_url: "https://github.com/ash-project/ash_archival",
      homepage_url: "https://github.com/ash-project/ash_archival",
      start_permanent: Mix.env() == :prod,
      description: @description,
      aliases: aliases(),
      package: package(),
      deps: deps(),
      docs: docs(),
      consolidate_protocols: Mix.env() != :test
    ]
  end

  defp package do
    [
      name: :ash_archival,
      licenses: ["MIT"],
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*
      CHANGELOG* documentation),
      links: %{
        GitHub: "https://github.com/ash-project/ash_archival"
      }
    ]
  end

  defp docs do
    [
      main: "archival",
      source_ref: "v#{@version}",
      extras: [
        "documentation/topics/archival.md",
        "documentation/topics/unarchiving.md",
        "documentation/dsls/DSL:-AshArchival.Resource.md"
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
          AshArchival,
          AshArchival.Resource
        ],
        Introspection: [
          AshArchival.Resource.Info
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
      {:ash, ash_version("~> 3.0.0-rc.0")},
      # dev/test dependencies
      {:simple_sat, "~> 0.1.0", only: [:dev, :test]},
      {:git_ops, "~> 2.5", only: [:dev, :test]},
      {:ex_doc, github: "elixir-lang/ex_doc", only: [:dev, :test], runtime: false},
      {:ex_check, "~> 0.14", only: [:dev, :test]},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:sobelow, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.14", only: [:dev, :test]}
    ]
  end

  defp aliases do
    [
      sobelow:
        "sobelow --skip -i Config.Secrets --ignore-files lib/migration_generator/migration_generator.ex",
      docs: [
        "spark.cheat_sheets",
        "docs",
        "spark.replace_doc_links",
        "spark.cheat_sheets_in_search"
      ],
      credo: "credo --strict",
      "spark.formatter": "spark.formatter --extensions AshArchival.Resource",
      "spark.cheat_sheets": "spark.cheat_sheets --extensions AshArchival.Resource",
      "spark.cheat_sheets_in_search":
        "spark.cheat_sheets_in_search --extensions AshArchival.Resource"
    ]
  end

  defp ash_version(default_version) do
    case System.get_env("ASH_VERSION") do
      nil -> default_version
      "local" -> [path: "../ash"]
      "main" -> [git: "https://github.com/ash-project/ash.git"]
      version -> "~> #{version}"
    end
  end
end
