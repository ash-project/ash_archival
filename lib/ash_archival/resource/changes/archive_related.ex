defmodule AshArchival.Resource.Changes.ArchiveRelated do
  @moduledoc false
  use Ash.Resource.Change
  require Ash.Query

  def change(changeset, _, context) do
    archive_related = AshArchival.Resource.Info.archive_related(changeset.resource)

    if Enum.empty?(archive_related) do
      changeset
    else
      Ash.Changeset.after_action(changeset, fn changeset, result ->
        # This is not optimized. We should do this with bulk queries, not resource actions.
        opts = context |> Ash.context_to_opts()
        loaded = changeset.api.load!(result, archive_related, opts)

        notifications =
          Enum.flat_map(archive_related, fn relationship ->
            relationship = Ash.Resource.Info.relationship(changeset.resource, relationship)

            destroy_action =
              Ash.Resource.Info.primary_action!(relationship.destination, :destroy).name

            loaded
            |> Map.get(relationship.name)
            |> List.wrap()
            |> Enum.flat_map(fn related ->
              related
              |> Ash.Changeset.for_destroy(destroy_action, %{}, opts)
              |> (relationship.api || changeset.api).destroy!(
                opts
                |> Keyword.merge(return_notifications?: true)
              )
            end)
          end)

        {:ok, result, notifications}
      end)
    end
  end
end
