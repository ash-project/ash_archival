defmodule AshStorage.Test.Post do
  @moduledoc false
  use Ash.Resource,
    domain: AshStorage.Test.Domain,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshStorage.Resource]

  storage do
    exclude_read_actions :all_posts
  end

  postgres do
    table("posts")
    repo(AshStorage.TestRepo)
  end

  attributes do
    uuid_primary_key(:id)
  end

  actions do
    default_accept(:*)
    defaults([:create, :read, :update, :destroy])

    read(:all_posts)

    update :unstorage do
      accept([])
      atomic_upgrade_with(:all_posts)
      change(set_attribute(:stored_at, nil))
    end
  end
end
