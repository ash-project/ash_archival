defmodule ArchivalTest do
  use ExUnit.Case

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

  defmodule Widget do
    use Ash.Resource,
      domain: ArchivalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource]

    ets do
      table(:widgets)
      private?(true)
    end

    actions do
      defaults([:read, :destroy, create: :*, update: :*])
    end

    attributes do
      uuid_primary_key(:id)
    end

    relationships do
      has_one :sprocket, ArchivalTest.Sprocket do
        public?(true)
        read_action(:read_for_widget)
      end
    end

    archive do
      archive_related [:sprocket]
    end
  end

  defmodule Sprocket do
    use Ash.Resource,
      domain: ArchivalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      authorizers: [Ash.Policy.Authorizer]

    ets do
      table(:sprockets)
      private?(true)
    end

    policies do
      policy action(:read_for_widget) do
        forbid_unless(context_equals(:actor, "Doc Brown"))
        forbid_unless(context_equals(:tenant, "Dr. E. Brown Enterprises"))
        authorize_if(always())
      end

      policy always() do
        authorize_if(always())
      end
    end

    actions do
      defaults([:read, :destroy, create: :*, update: :*])

      read :read_for_widget do
      end
    end

    attributes do
      uuid_primary_key(:id)
    end

    relationships do
      belongs_to :widget, ArchivalTest.Widget do
        public?(true)
      end
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
      resource(Sprocket)
      resource(Widget)
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

  test "destroyed records can be returned" do
    author =
      Author
      |> Ash.Changeset.for_create(:create)
      |> Ash.create!()

    assert {:ok, %{archived_at: archived_at}} = Ash.destroy(author, return_destroyed?: true)
    assert archived_at
  end

  test "the actor and tenant are passed through to related read actions when destroying" do
    widget = Widget |> Ash.create!(%{}, authorize?: false)
    sprocket = Sprocket |> Ash.create!(%{widget_id: widget.id})

    assert {:ok, widget} =
             widget
             |> Ash.Changeset.for_destroy(:destroy, %{},
               actor: "Doc Brown",
               tenant: "Dr. E. Brown Enterprises"
             )
             |> Ash.destroy(return_destroyed?: true)

    assert widget.archived_at

    assert {:error, _} = Ash.reload(sprocket)
  end
end
