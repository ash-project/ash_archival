defmodule AshArchival.Resource.Changes.FilterArchivedForUpserts do
  @moduledoc false
  use Ash.Resource.Change

  def change(changeset, _, _) do
    if changeset.context.private[:upsert?] &&
         !AshArchival.Resource.Info.archive_base_filter?(changeset.resource) do
      attribute = AshArchival.Resource.Info.archive_attribute!(changeset.resource)
      Ash.Changeset.filter(changeset, expr(is_nil(^ref(attribute))))
    else
      changeset
    end
  end

  def atomic(changeset, opts, context) do
    change(changeset, opts, context)
  end
end
