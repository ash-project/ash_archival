# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshArchival.Test.Post do
  @moduledoc false
  use Ash.Resource,
    domain: AshArchival.Test.Domain,
    data_layer: AshPostgres.DataLayer,
    fragments: [AshArchival.Test.Post.Archival]

  postgres do
    table("posts")
    repo(AshArchival.TestRepo)
  end

  attributes do
    uuid_primary_key(:id)
  end

  actions do
    default_accept(:*)
    defaults([:create, :read, :update, :destroy])

    read(:all_posts)

    update :unarchive do
      accept([])
      atomic_upgrade_with(:all_posts)
      change(set_attribute(:archived_at, nil))
    end
  end
end
