# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule ArchiveRelatedContextTest do
  use ExUnit.Case

  # The parent's destroy actions run `SetSharedMarker` after the `ArchiveRelated`
  # change that ash_archival prepends. The child's destroy sends the shared context
  # it receives to the test process, so the tests can assert that `archive_related`
  # forwards shared context set after `ArchiveRelated` ran.

  defmodule SetSharedMarker do
    use Ash.Resource.Change

    def change(changeset, _, _), do: set_marker(changeset)

    def atomic(changeset, _, _), do: {:ok, set_marker(changeset)}

    defp set_marker(changeset) do
      Ash.Changeset.set_context(changeset, %{shared: %{marker: :from_parent}})
    end
  end

  defmodule ReportSharedMarker do
    use Ash.Resource.Change

    def change(changeset, _, _), do: report(changeset)

    def atomic(changeset, _, _), do: {:ok, report(changeset)}

    defp report(changeset) do
      send(self(), {:child_shared_marker, changeset.context[:shared][:marker]})
      changeset
    end
  end

  defmodule Parent do
    use Ash.Resource,
      domain: ArchiveRelatedContextTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource]

    ets do
      private?(true)
    end

    archive do
      archive_related([:children])
    end

    actions do
      default_accept(:*)
      defaults([:create, :read])

      destroy :destroy do
        primary?(true)
        require_atomic?(false)
        change(SetSharedMarker)
      end

      destroy :destroy_atomic do
        require_atomic?(true)
        change(SetSharedMarker)
      end
    end

    attributes do
      uuid_primary_key(:id)
    end

    relationships do
      has_many(:children, ArchiveRelatedContextTest.Child) do
        public?(true)
      end
    end
  end

  defmodule Child do
    use Ash.Resource,
      domain: ArchiveRelatedContextTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource]

    ets do
      private?(true)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read])

      destroy :destroy do
        primary?(true)
        change(ReportSharedMarker)
      end
    end

    attributes do
      uuid_primary_key(:id)
    end

    relationships do
      belongs_to(:parent, ArchiveRelatedContextTest.Parent) do
        public?(true)
        attribute_writable?(true)
      end
    end
  end

  defmodule Domain do
    use Ash.Domain

    resources do
      resource(Parent)
      resource(Child)
    end
  end

  setup do
    parent = Ash.create!(Parent, %{})
    Ash.create!(Child, %{parent_id: parent.id})
    %{parent: parent}
  end

  test "non-atomic archive passes shared context set after ArchiveRelated to archived children",
       %{parent: parent} do
    Ash.destroy!(parent, action: :destroy)

    assert_received {:child_shared_marker, :from_parent}
  end

  test "atomic archive passes shared context set after ArchiveRelated to archived children",
       %{parent: parent} do
    Ash.destroy!(parent, action: :destroy_atomic)

    assert_received {:child_shared_marker, :from_parent}
  end
end
