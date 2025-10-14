# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshArchival.Resource.Preparations.FilterArchived do
  @moduledoc false
  use Ash.Resource.Preparation

  def prepare(query, _, _) do
    excluded_actions =
      AshArchival.Resource.Info.archive_exclude_read_actions!(query.resource)

    if query.action.name in excluded_actions ||
         AshArchival.Resource.Info.archive_base_filter?(query.resource) do
      query
    else
      attribute = AshArchival.Resource.Info.archive_attribute!(query.resource)
      Ash.Query.filter(query, is_nil(^ref(attribute)))
    end
  end
end
