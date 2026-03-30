# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule ArchivalTest do
  use ExUnit.Case

  require Ash.Query

  defmodule Author do
    use Ash.Resource,
      domain: ArchivalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource]

    ets do
      table(:authors)
      private?(true)
    end

    archive do
      archive_related([:posts])
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
    end

    relationships do
      has_many(:posts, ArchivalTest.Post) do
        public?(true)
      end
    end
  end

  defmodule AuthorWithArchive do
    use Ash.Resource,
      domain: ArchivalTest.Domain,
      data_layer: Ash.DataLayer.Ets

    ets do
      table(:authors)
      private?(true)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:archived_at, :utc_datetime_usec, public?: true)
    end
  end

  defmodule Post do
    use Ash.Resource,
      domain: ArchivalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource]

    ets do
      table(:posts)
      private?(true)
    end

    archive do
      archive_related([:comments])
      exclude_read_actions :all_posts
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
      create(:upsert)

      read(:all_posts)

      update :unarchive do
        accept([])
        atomic_upgrade_with(:all_posts)
        change(set_attribute(:archived_at, nil))
      end
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:name, :string, public?: true)
      attribute(:title, :string, public?: true)
    end

    identities do
      identity(:unique_name, [:name], pre_check?: true, where: expr(is_nil(archived_at)))
      identity(:unique_title, [:title], pre_check?: true)
    end

    relationships do
      belongs_to :author, Author do
        public?(true)
        attribute_writable?(true)
      end

      has_many(:comments, ArchivalTest.Comment) do
        public?(true)
      end
    end
  end

  defmodule UnarchivablePost do
    use Ash.Resource,
      domain: ArchivalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource]

    ets do
      table(:posts)
      private?(true)
    end

    archive do
      exclude_read_actions :all_posts
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

    attributes do
      uuid_primary_key(:id)
    end
  end

  defmodule PostWithArchive do
    use Ash.Resource,
      domain: ArchivalTest.Domain,
      data_layer: Ash.DataLayer.Ets

    ets do
      table(:posts)
      private?(true)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:archived_at, :utc_datetime_usec, public?: true)
    end
  end

  defmodule Comment do
    use Ash.Resource,
      domain: ArchivalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource]

    ets do
      table(:comments)
      private?(true)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
    end

    relationships do
      belongs_to :post, Post do
        public?(true)
        attribute_writable?(true)
      end
    end
  end

  defmodule CommentWithArchive do
    use Ash.Resource,
      domain: ArchivalTest.Domain,
      data_layer: Ash.DataLayer.Ets

    ets do
      table(:comments)
      private?(true)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:archived_at, :utc_datetime_usec, public?: true)
    end
  end

  # Resource for testing update behaviour on archived records across
  # different action configurations and code paths.
  defmodule UpdatableRecord do
    use Ash.Resource,
      domain: ArchivalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource]

    ets do
      table(:updatable_records)
      private?(true)
    end

    archive do
      exclude_read_actions(:all_records)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :destroy])

      read :all_records do
        pagination(keyset?: true, required?: false)
      end

      # Non-atomic: both require_atomic? and atomic_upgrade? are false
      update :non_atomic_update do
        require_atomic?(false)
        atomic_upgrade?(false)
      end

      # Atomic: require_atomic? true, uses primary read (has archival filter)
      update :atomic_update do
        require_atomic?(true)
      end

      # Atomic with upgrade: atomic_upgrade? true, uses primary read (has archival filter)
      update :atomic_upgrade_update do
        require_atomic?(false)
        atomic_upgrade?(true)
      end

      # Atomic with excluded read: uses a read action that skips the archival filter
      update :atomic_with_excluded_read do
        require_atomic?(true)
        atomic_upgrade_with(:all_records)
      end
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:name, :string, public?: true)
    end
  end

  # Raw view of the same ETS table (no archival extension) for reading archived records
  defmodule UpdatableRecordRaw do
    use Ash.Resource,
      domain: ArchivalTest.Domain,
      data_layer: Ash.DataLayer.Ets

    ets do
      table(:updatable_records)
      private?(true)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:name, :string, public?: true)
      attribute(:archived_at, :utc_datetime_usec, public?: true)
    end
  end

  defmodule Domain do
    use Ash.Domain

    resources do
      resource(Author)
      resource(AuthorWithArchive)
      resource(Post)
      resource(UnarchivablePost)
      resource(PostWithArchive)
      resource(Comment)
      resource(CommentWithArchive)
      resource(UpdatableRecord)
      resource(UpdatableRecordRaw)
    end
  end

  test "destroying a record archives it" do
    post =
      Post
      |> Ash.Changeset.for_create(:create)
      |> Ash.create!()

    assert :ok = post |> Ash.destroy!()

    [archived] = Ash.read!(PostWithArchive)
    assert archived.id == post.id
    assert archived.archived_at
  end

  test "archived records are hidden" do
    post =
      Post
      |> Ash.Changeset.for_create(:create)
      |> Ash.create!()

    assert :ok = post |> Ash.destroy!()

    assert [] = Ash.read!(Post)
  end

  test "archived records can be unarchived" do
    assert %UnarchivablePost{} =
             UnarchivablePost
             |> Ash.Changeset.for_create(:create)
             |> Ash.create!()
             |> Ash.Changeset.for_update(:unarchive)
             |> Ash.update!()
  end

  test "upserts don't consider archived records if included in the identity" do
    post =
      Post
      |> Ash.Changeset.for_create(:create, %{name: "fred"})
      |> Ash.create!()

    assert :ok = post |> Ash.destroy!()

    Post
    |> Ash.Changeset.for_create(:create, %{name: "fred"},
      upsert?: true,
      upsert_identity: :unique_name
    )
    |> Ash.create!()

    assert [_, _] =
             Post
             |> Ash.Query.for_read(:all_posts)
             |> Ash.read!()
  end

  test "upserts do consider archived records if not included in the identity" do
    post =
      Post
      |> Ash.Changeset.for_create(:create, %{title: "fred"})
      |> Ash.create!()

    assert :ok = post |> Ash.destroy!()

    Post
    |> Ash.Changeset.for_create(:upsert, %{title: "fred"},
      upsert?: true,
      upsert_identity: :unique_title
    )
    |> Ash.create!()

    assert [_] =
             Post
             |> Ash.Query.for_read(:all_posts)
             |> Ash.read!()
  end

  test "destroying a record archives any `archive_related` it has configured" do
    post =
      Post
      |> Ash.Changeset.for_create(:create)
      |> Ash.create!()

    comment =
      Comment
      |> Ash.Changeset.for_create(:create, %{post_id: post.id})
      |> Ash.create!()

    assert :ok = post |> Ash.destroy!()

    [archived] = Ash.read!(CommentWithArchive)
    assert archived.id == comment.id
    assert archived.archived_at
  end

  test "destroying a record triggers a cascading archive." do
    author =
      Author
      |> Ash.Changeset.for_create(:create)
      |> Ash.create!()

    post =
      Post
      |> Ash.Changeset.for_create(:create, %{author_id: author.id})
      |> Ash.create!()

    comment =
      Comment
      |> Ash.Changeset.for_create(:create, %{post_id: post.id})
      |> Ash.create!()

    assert :ok = author |> Ash.destroy!()

    [archived_post] = Ash.read!(PostWithArchive)
    assert archived_post.id == post.id
    assert archived_post.archived_at

    [archived_comment] = Ash.read!(CommentWithArchive)
    assert archived_comment.id == comment.id
    assert archived_comment.archived_at
  end

  # Helper: create and archive a record, return it as a loaded UpdatableRecord struct
  defp create_and_archive(name) do
    record =
      UpdatableRecord
      |> Ash.Changeset.for_create(:create, %{name: name})
      |> Ash.create!()

    Ash.destroy!(record)

    [archived] =
      UpdatableRecordRaw
      |> Ash.Query.filter(id == ^record.id)
      |> Ash.read!()

    %UpdatableRecord{
      id: archived.id,
      name: archived.name,
      archived_at: archived.archived_at,
      __meta__: %Ecto.Schema.Metadata{state: :loaded, source: "updatable_records"}
    }
  end

  # Helper: read the actual ETS state to verify if an update really happened
  defp read_raw(id) do
    [record] =
      UpdatableRecordRaw
      |> Ash.Query.filter(id == ^id)
      |> Ash.read!()

    record
  end

  # ── Non-atomic path (require_atomic?: false, atomic_upgrade?: false) ──
  # The non-atomic path calls Ash.DataLayer.update/2 directly with
  # changeset.filter = nil, so the archival filter is never involved.

  test "non-atomic update/2 on archived record succeeds and updates" do
    archived = create_and_archive("original")

    assert {:ok, updated} =
             archived
             |> Ash.Changeset.for_update(:non_atomic_update, %{name: "updated"})
             |> Ash.update()

    assert updated.name == "updated"
    assert read_raw(archived.id).name == "updated"
  end

  test "non-atomic bulk_update/3 on archived record silently returns 0 records and does not update" do
    archived = create_and_archive("original")

    result =
      Ash.bulk_update([archived], :non_atomic_update, %{name: "updated"},
        resource: UpdatableRecord,
        return_records?: true,
        return_errors?: true
      )

    assert result.status == :success
    assert result.records == []
    assert result.error_count == 0
    assert read_raw(archived.id).name == "original"
  end

  # ── Atomic path with default read (has archival filter) ──
  # The atomic upgrade path builds a read query using the primary read action.
  # AshArchival's FilterArchived preparation adds is_nil(archived_at) to that
  # query, so it returns 0 rows for archived records.

  test "atomic update/2 on archived record raises StaleRecord" do
    archived = create_and_archive("original")

    assert {:error, %Ash.Error.Invalid{errors: [%Ash.Error.Changes.StaleRecord{}]}} =
             archived
             |> Ash.Changeset.for_update(:atomic_update, %{name: "updated"})
             |> Ash.update()

    assert read_raw(archived.id).name == "original"
  end

  test "atomic_upgrade update/2 on archived record raises StaleRecord" do
    archived = create_and_archive("original")

    assert {:error, %Ash.Error.Invalid{errors: [%Ash.Error.Changes.StaleRecord{}]}} =
             archived
             |> Ash.Changeset.for_update(:atomic_upgrade_update, %{name: "updated"})
             |> Ash.update()

    assert read_raw(archived.id).name == "original"
  end

  test "atomic bulk_update/3 on archived record silently returns 0 records and does not update" do
    archived = create_and_archive("original")

    result =
      Ash.bulk_update([archived], :atomic_update, %{name: "updated"},
        resource: UpdatableRecord,
        return_records?: true,
        return_errors?: true
      )

    assert result.status == :success
    assert result.records == []
    assert result.error_count == 0
    assert read_raw(archived.id).name == "original"
  end

  test "atomic_upgrade bulk_update/3 on archived record silently returns 0 records and does not update" do
    archived = create_and_archive("original")

    result =
      Ash.bulk_update([archived], :atomic_upgrade_update, %{name: "updated"},
        resource: UpdatableRecord,
        return_records?: true,
        return_errors?: true
      )

    assert result.status == :success
    assert result.records == []
    assert result.error_count == 0
    assert read_raw(archived.id).name == "original"
  end

  # ── Atomic path with excluded read (no archival filter) ──
  # When atomic_upgrade_with points to a read action excluded from AshArchival,
  # the archival filter is not applied, so the record is found and updated.

  test "atomic update/2 with excluded read on archived record succeeds and updates" do
    archived = create_and_archive("original")

    assert {:ok, updated} =
             archived
             |> Ash.Changeset.for_update(:atomic_with_excluded_read, %{name: "updated"})
             |> Ash.update()

    assert updated.name == "updated"
    assert read_raw(archived.id).name == "updated"
  end

  test "atomic bulk_update/3 with excluded read on archived record succeeds and updates" do
    archived = create_and_archive("original")

    result =
      Ash.bulk_update([archived], :atomic_with_excluded_read, %{name: "updated"},
        resource: UpdatableRecord,
        return_records?: true,
        return_errors?: true
      )

    assert result.status == :success
    assert [%{name: "updated"}] = result.records
    assert result.error_count == 0
    assert read_raw(archived.id).name == "updated"
  end

  test "destroyed records can be returned" do
    author =
      Author
      |> Ash.Changeset.for_create(:create)
      |> Ash.create!()

    assert {:ok, %{archived_at: archived_at}} = Ash.destroy(author, return_destroyed?: true)
    assert archived_at
  end
end
