defmodule AshArchival.MixProject do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :ash_archival,
      version: @version,
      elixir: "~> 1.13",
      source_url: "https://github.com/ash-project/ash_archival",
      homepage_url: "https://github.com/ash-project/ash_archival",
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      package: package(),
      deps: deps(),
      docs: docs(),
      consolidate_protocols: Mix.env() != :test
    ]
  end

  defp package do
    [
      name: :ash_postgres,
      licenses: ["MIT"],
      links: %{
        GitHub: "https://github.com/ash-project/ash_archival"
      }
    ]
  end

  defp docs do
    [
      main: "readme",
      source_ref: "v#{@version}"
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
      # {:ash, ash_version("~> 1.52.0-rc.17")},
      {:ash, path: "../../ash/ash"},
      {:git_ops, "~> 2.4.5", only: :dev},
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:ex_check, "~> 0.14", only: :dev},
      {:credo, ">= 0.0.0", only: :dev, runtime: false},
      {:dialyxir, ">= 0.0.0", only: :dev, runtime: false},
      {:sobelow, ">= 0.0.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: [:dev, :test]},
      {:elixir_sense, github: "elixir-lsp/elixir_sense", only: [:dev, :test]}
    ]
  end

  defp aliases do
    [
      sobelow:
        "sobelow --skip -i Config.Secrets --ignore-files lib/migration_generator/migration_generator.ex",
      credo: "credo --strict",
      "ash.formatter": "ash.formatter --extensions AshArchival.Resource"
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
