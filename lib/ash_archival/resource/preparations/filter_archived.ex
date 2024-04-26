defmodule AshArchival.Resource.Preparations.FilterArchived do
  @moduledoc false
  use Ash.Resource.Preparation

  def prepare(query, _, _) do
    excluded_actions =
      AshArchival.Resource.Info.archive_exclude_read_actions!(query.resource)

    if query.action.name in excluded_actions do
      query
    else
      attribute = AshArchival.Resource.Info.archive_attribute!(query.resource)
      Ash.Query.filter(query, is_nil(^ref(attribute)))
    end
  end
end
