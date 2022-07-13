defmodule AshArchival.DocIndex do
  @moduledoc """
  Some documentation for AshArchival.
  """

  use Ash.DocIndex,
    otp_app: :ash,
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
  @spec code_modules :: [{String.t(), list(module)}]
  def code_modules do
    [
      {"Archival",
       [
         AshArchival.Resource
       ]}
    ]
  end
end
