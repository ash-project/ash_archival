defmodule AshArchival.MixProject do
  use Mix.Project

  @version "0.1.3"
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
      extras: Path.wildcard("documentation/**/*.md"),
      spark: [
        extensions: [
          %{
            module: AshArchival.Resource,
            name: "Resource Archival",
            default_for_target?: false,
            target: "Ash.Resource",
            type: "Resource"
          }
        ]
      ],
      groups_for_modules: [
        Extension: [
          AshArchival,
          AshArchival.Resource
        ],
        Introspection: [
          AshArchival.Resource.Info
        ],
        Transformers: [
          ~r/AshArchival.Resource.Transformers.*/
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
      {:ash, ash_version("~> 2.0")},
      {:git_ops, "~> 2.4.5", only: [:dev, :test]},
      {:ex_doc, "~> 0.22", only: [:dev, :test], runtime: false},
      {:ex_check, "~> 0.14", only: [:dev, :test]},
      {:credo, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:dialyxir, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:sobelow, ">= 0.0.0", only: [:dev, :test], runtime: false},
      {:excoveralls, "~> 0.14", only: [:dev, :test]},
      {:elixir_sense, github: "elixir-lsp/elixir_sense", only: [:dev, :test]}
    ]
  end

  defp aliases do
    [
      sobelow:
        "sobelow --skip -i Config.Secrets --ignore-files lib/migration_generator/migration_generator.ex",
      docs: ["docs", "ash.replace_doc_links"],
      credo: "credo --strict",
      "spark.formatter": "spark.formatter --extensions AshArchival.Resource"
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
