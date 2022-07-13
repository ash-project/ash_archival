defmodule AshArchival.Resource do
  @moduledoc """
  Configures a resource to be archived instead of destroyed for all destroy actions.

  What does this resource extension do?

  1. Adds a private `archived_at` `utc_datetime_usec` attribute.
  1. Marks all
  """

  @archive %Ash.Dsl.Section{
    name: :archive,
    describe: "A section for configuring how archival is configured for a resource.",
    schema: [
      archive_related: [
        type: {:list, :atom},
        doc: """
        A list of relationships that should have all related items archived when this is archived.
        Note: this is currently not optimized. It simply reads the relationship and archives each one
        (by calling its primary destroy, so the related resource must also use the archival extension).
        When bulk actions are supported by Ash then this can be updated to use those.
        """
      ]
    ]
  }

  use Ash.Dsl.Extension,
    sections: [@archive],
    transformers: [AshArchival.Resource.Transformers.SetupArchival]

  def archive_related(resource) do
    Ash.Dsl.Extension.get_opt(resource, [:archive], :archive_related, [])
  end
end
