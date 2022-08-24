defmodule AshArchival.DocIndex do
  @moduledoc false

  use Spark.DocIndex,
    otp_app: :ash_archival,
    guides_from: [
      "documentation/**/*.md"
    ]

  @impl true
  @spec for_library() :: String.t()
  def for_library, do: "ash_archival"

  @impl true
  @spec extensions() :: list(Ash.DocIndex.extension())
  def extensions do
    [
      %{
        module: AshArchival.Resource,
        name: "Resource Archival",
        target: "Ash.Resource.Archival",
        type: "Resource"
      }
    ]
  end

  @impl true
  def code_modules do
    [
      {"Introspection",
       [
         AshArchival.Info
       ]}
    ]
  end
end
