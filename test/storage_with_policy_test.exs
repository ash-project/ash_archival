defmodule StorageWithPolicyTest do
  use ExUnit.Case

  defmodule Author do
    use Ash.Resource,
      domain: StorageWithPolicyTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshStorage.Resource],
      authorizers: [Ash.Policy.Authorizer]

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
      has_many(:posts, StorageWithPolicyTest.Post) do
        public?(true)
      end
    end

    policies do
      policy always() do
        authorize_if(action_type(:create))
        authorize_if(action_type(:read))
        authorize_if(actor_attribute_equals(:admin, true))
      end
    end
  end

  defmodule AuthorWithStorage do
    use Ash.Resource,
      domain: StorageWithPolicyTest.Domain,
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
      domain: StorageWithPolicyTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshStorage.Resource],
      authorizers: [Ash.Policy.Authorizer]

    ets do
      table(:posts)
      private?(true)
    end

    storage do
      storage_related([:comments])
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
    end

    relationships do
      belongs_to :author, Author do
        public?(true)
        attribute_writable?(true)
      end

      has_many(:comments, StorageWithPolicyTest.Comment) do
        public?(true)
      end
    end

    policies do
      policy always() do
        authorize_if(action_type(:create))
        authorize_if(action_type(:read))
        authorize_if(actor_attribute_equals(:admin, true))
      end
    end
  end

  defmodule PostWithStorage do
    use Ash.Resource,
      domain: StorageWithPolicyTest.Domain,
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
      domain: StorageWithPolicyTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshStorage.Resource],
      authorizers: [Ash.Policy.Authorizer]

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

    policies do
      policy always() do
        authorize_if(action_type(:create))
        authorize_if(action_type(:read))
        authorize_if(actor_attribute_equals(:admin, true))
      end
    end
  end

  defmodule CommentWithStorage do
    use Ash.Resource,
      domain: StorageWithPolicyTest.Domain,
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

    authorization do
      authorize(:always)
    end

    resources do
      resource(Author)
      resource(AuthorWithStorage)
      resource(Post)
      resource(PostWithStorage)
      resource(Comment)
      resource(CommentWithStorage)
    end
  end

  test "destroying a record stores it" do
    comment =
      Comment
      |> Ash.Changeset.for_create(:create)
      |> Ash.create!()

    assert :ok = comment |> Ash.destroy!(actor: %{admin: true})

    [stored] = Ash.read!(CommentWithStorage)
    assert stored.id == comment.id
    assert stored.stored_at
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

    assert :ok = post |> Ash.destroy!(actor: %{admin: true})

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

    assert :ok = author |> Ash.destroy!(actor: %{admin: true})

    [stored_post] = Ash.read!(PostWithStorage)
    assert stored_post.id == post.id
    assert stored_post.stored_at

    [stored_comment] = Ash.read!(CommentWithStorage)
    assert stored_comment.id == comment.id
    assert stored_comment.stored_at
  end
end
