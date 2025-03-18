defmodule CreateArgs do
  @moduledoc """
  The behaviour for specifiying arguments for related resources
  """
  @behaviour AshStorage.StorageRelatedArguments

  @impl true
  def arguments(arguments, _rel, _opts) do
    %{arg: arguments[:arg]}
  end
end

defmodule AshStorage.Test.WithArgsParent do
  @moduledoc false
  use Ash.Resource,
    domain: AshStorage.Test.Domain,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshStorage.Resource]

  storage do
    exclude_read_actions :read
    storage_related [:children]

    storage_related_arguments CreateArgs
  end

  postgres do
    table("with_args_parents")
    repo(AshStorage.TestRepo)
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:arg1, :string)
  end

  actions do
    default_accept(:*)
    defaults([:create, :read, :update])

    destroy :storage do
      primary?(true)
      accept([])

      argument :arg, :string do
        allow_nil?(false)
      end

      change(set_attribute(:arg1, arg(:arg)))
    end
  end

  relationships do
    has_many(:children, AshStorage.Test.WithArgsChild) do
      destination_attribute(:parent_id)
      source_attribute(:id)
    end
  end
end

defmodule AshStorage.Test.WithArgsChild do
  @moduledoc false
  use Ash.Resource,
    domain: AshStorage.Test.Domain,
    data_layer: AshPostgres.DataLayer,
    extensions: [AshStorage.Resource]

  storage do
    exclude_read_actions :read
  end

  postgres do
    table("with_args_children")
    repo(AshStorage.TestRepo)
  end

  attributes do
    uuid_primary_key(:id)
    attribute(:arg1, :string)
  end

  actions do
    default_accept(:*)
    defaults([:create, :read, :update])

    destroy :storage do
      primary?(true)
      accept([])

      argument :arg, :string do
        allow_nil?(false)
      end

      change(set_attribute(:arg1, arg(:arg)))
    end
  end

  relationships do
    belongs_to(:parent, AshStorage.Test.WithArgsParent) do
      public?(true)
    end
  end
end
