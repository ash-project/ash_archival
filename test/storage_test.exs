defmodule StorageTest do
  use ExUnit.Case

  defmodule Author do
    use Ash.Resource,
      domain: StorageTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshStorage.Resource]

    ets do
      table(:authors)
      private?(true)
    end

    storage do
      storage_related([:posts])
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
    end

    relationships do
      has_many(:posts, StorageTest.Post) do
        public?(true)
      end
    end
  end

  defmodule AuthorWithStorage do
    use Ash.Resource,
      domain: StorageTest.Domain,
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
      attribute(:stored_at, :utc_datetime_usec, public?: true)
    end
  end

  defmodule Post do
    use Ash.Resource,
      domain: StorageTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshStorage.Resource]

    ets do
      table(:posts)
      private?(true)
    end

    storage do
      storage_related([:comments])
      exclude_read_actions :all_posts
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
      create(:upsert)

      read(:all_posts)

      update :unstorage do
        accept([])
        atomic_upgrade_with(:all_posts)
        change(set_attribute(:stored_at, nil))
      end
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:name, :string, public?: true)
      attribute(:title, :string, public?: true)
    end

    identities do
      identity(:unique_name, [:name], pre_check?: true, where: expr(is_nil(stored_at)))
      identity(:unique_title, [:title], pre_check?: true)
    end

    relationships do
      belongs_to :author, Author do
        public?(true)
        attribute_writable?(true)
      end

      has_many(:comments, StorageTest.Comment) do
        public?(true)
      end
    end
  end

  defmodule UnstorageablePost do
    use Ash.Resource,
      domain: StorageTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshStorage.Resource]

    ets do
      table(:posts)
      private?(true)
    end

    storage do
      exclude_read_actions :all_posts
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

    attributes do
      uuid_primary_key(:id)
    end
  end

  defmodule PostWithStorage do
    use Ash.Resource,
      domain: StorageTest.Domain,
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
      attribute(:stored_at, :utc_datetime_usec, public?: true)
    end
  end

  defmodule Comment do
    use Ash.Resource,
      domain: StorageTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshStorage.Resource]

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

  defmodule CommentWithStorage do
    use Ash.Resource,
      domain: StorageTest.Domain,
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
      attribute(:stored_at, :utc_datetime_usec, public?: true)
    end
  end

  defmodule Domain do
    use Ash.Domain

    resources do
      resource(Author)
      resource(AuthorWithStorage)
      resource(Post)
      resource(UnstorageablePost)
      resource(PostWithStorage)
      resource(Comment)
      resource(CommentWithStorage)
    end
  end

  test "destroying a record stores it" do
    post =
      Post
      |> Ash.Changeset.for_create(:create)
      |> Ash.create!()

    assert :ok = post |> Ash.destroy!()

    [stored] = Ash.read!(PostWithStorage)
    assert stored.id == post.id
    assert stored.stored_at
  end

  test "stored records are hidden" do
    post =
      Post
      |> Ash.Changeset.for_create(:create)
      |> Ash.create!()

    assert :ok = post |> Ash.destroy!()

    assert [] = Ash.read!(Post)
  end

  test "stored records can be unstored" do
    assert %UnstorageablePost{} =
             UnstorageablePost
             |> Ash.Changeset.for_create(:create)
             |> Ash.create!()
             |> Ash.Changeset.for_update(:unstorage)
             |> Ash.update!()
  end

  test "upserts don't consider stored records if included in the identity" do
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

  test "upserts do consider stored records if not included in the identity" do
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

  test "destroying a record stores any `storage_related` it has configured" do
    post =
      Post
      |> Ash.Changeset.for_create(:create)
      |> Ash.create!()

    comment =
      Comment
      |> Ash.Changeset.for_create(:create, %{post_id: post.id})
      |> Ash.create!()

    assert :ok = post |> Ash.destroy!()

    [stored] = Ash.read!(CommentWithStorage)
    assert stored.id == comment.id
    assert stored.stored_at
  end

  test "destroying a record triggers a cascading storage." do
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

    [stored_post] = Ash.read!(PostWithStorage)
    assert stored_post.id == post.id
    assert stored_post.stored_at

    [stored_comment] = Ash.read!(CommentWithStorage)
    assert stored_comment.id == comment.id
    assert stored_comment.stored_at
  end

  test "destroyed records can be returned" do
    author =
      Author
      |> Ash.Changeset.for_create(:create)
      |> Ash.create!()

    assert {:ok, %{stored_at: stored_at}} = Ash.destroy(author, return_destroyed?: true)
    assert stored_at
  end
end
