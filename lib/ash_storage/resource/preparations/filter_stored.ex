defmodule AshStorage.Resource.Preparations.FilterStored do
  @moduledoc false
  use Ash.Resource.Preparation

  def prepare(query, _, _) do
    excluded_actions =
      AshStorage.Resource.Info.storage_exclude_read_actions!(query.resource)

    if query.action.name in excluded_actions ||
         AshStorage.Resource.Info.storage_base_filter?(query.resource) do
      query
    else
      attribute = AshStorage.Resource.Info.storage_attribute!(query.resource)
      Ash.Query.filter(query, is_nil(^ref(attribute)))
    end
  end
end
