defmodule AshArchival.Test.Post do
  @moduledoc false
  use Ash.Resource,
    domain: AshArchival.Test.Domain,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  archive do
    exclude_read_actions :all_posts
  end

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
