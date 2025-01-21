defmodule AshArchival.Test.WithArgsParent do
  @moduledoc false
  use Ash.Resource,
    domain: AshArchival.Test.Domain,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  archive do
    exclude_read_actions :read
    archive_related [:children]

    archive_related_arguments(fn arguments, _ ->
      %{arg: arguments[:arg]}
    end)
  end

  postgres do
    table("with_args_parents")
    repo(AshArchival.TestRepo)
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:arg1, :string)
  end

  actions do
    default_accept(:*)
    defaults([:create, :read, :update])

    destroy :archive do
      primary?(true)
      accept([])

      argument :arg, :string do
        allow_nil?(false)
      end

      change(set_attribute(:arg1, arg(:arg)))
    end
  end

  relationships do
    has_many(:children, AshArchival.Test.WithArgsChild) do
      destination_attribute(:parent_id)
      source_attribute(:id)
    end
  end
end

defmodule AshArchival.Test.WithArgsChild do
  @moduledoc false
  use Ash.Resource,
    domain: AshArchival.Test.Domain,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshArchival.Resource]

  archive do
    exclude_read_actions :read
  end

  postgres do
    table("with_args_children")
    repo(AshArchival.TestRepo)
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:arg1, :string)
  end

  actions do
    default_accept(:*)
    defaults([:create, :read, :update])

    destroy :archive do
      primary?(true)
      accept([])

      argument :arg, :string do
        allow_nil?(false)
      end

      change(set_attribute(:arg1, arg(:arg)))
    end
  end

  relationships do
    belongs_to(:parent, AshArchival.Test.WithArgsParent) do
      public?(true)
    end
  end
end
