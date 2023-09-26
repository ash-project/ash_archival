defmodule AshArchival.Resource do
  @archive %Spark.Dsl.Section{
    name: :archive,
    describe: "A section for configuring how archival is configured for a resource.",
    schema: [
      archive_related: [
        type: {:list, :atom},
        doc: """
        A list of relationships that should have all related items archived when this is archived. Note: this is currently not optimized. It simply reads the relationship and archives each one.
        """
      ]
    ]
  }

  @moduledoc """
  Configures a resource to be archived instead of destroyed for all destroy actions.

  For more information, see [Archival](/documentation/topics/archival.md)

  <!--- ash-hq-hide-start --> <!--- -->

  ## DSL Documentation

  ### Index

  #{Spark.Dsl.Extension.doc_index([@archive])}

  ### Docs

  #{Spark.Dsl.Extension.doc([@archive])}
  <!--- ash-hq-hide-stop--> <!--- -->
  """

  use Spark.Dsl.Extension,
    sections: [@archive],
    transformers: [AshArchival.Resource.Transformers.SetupArchival]
end
