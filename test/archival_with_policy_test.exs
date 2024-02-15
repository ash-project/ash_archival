defmodule ArchivalWithPolicyTest do
  use ExUnit.Case

  defmodule Author do
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource],
      authorizers: [Ash.Policy.Authorizer]

    ets do
      table(:authors)
      private?(true)
    end

    archive do
      archive_related([:posts])
    end

    actions do
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
    end

    relationships do
      has_many(:posts, ArchivalWithPolicyTest.Post)
    end

    policies do
      policy always() do
        authorize_if(action_type(:create))
        authorize_if(action_type(:read))
        authorize_if(actor_attribute_equals(:admin, true))
      end
    end
  end

  defmodule AuthorWithArchive do
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets

    ets do
      table(:authors)
      private?(true)
    end

    actions do
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:archived_at, :utc_datetime_usec)
    end
  end

  defmodule Post do
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource],
      authorizers: [Ash.Policy.Authorizer]

    ets do
      table(:posts)
      private?(true)
    end

    archive do
      archive_related([:comments])
    end

    actions do
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
    end

    relationships do
      belongs_to :author, Author do
        attribute_writable?(true)
      end

      has_many(:comments, ArchivalWithPolicyTest.Comment)
    end

    policies do
      policy always() do
        authorize_if(action_type(:create))
        authorize_if(action_type(:read))
        authorize_if(actor_attribute_equals(:admin, true))
      end
    end
  end

  defmodule PostWithArchive do
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets

    ets do
      table(:posts)
      private?(true)
    end

    actions do
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:archived_at, :utc_datetime_usec)
    end
  end

  defmodule Comment do
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource],
      authorizers: [Ash.Policy.Authorizer]

    ets do
      table(:comments)
      private?(true)
    end

    actions do
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
    end

    relationships do
      belongs_to :post, Post do
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

  defmodule CommentWithArchive do
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets

    ets do
      table(:comments)
      private?(true)
    end

    actions do
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:archived_at, :utc_datetime_usec)
    end
  end

  defmodule Registry do
    use Ash.Registry

    entries do
      entry(Author)
      entry(AuthorWithArchive)
      entry(Post)
      entry(PostWithArchive)
      entry(Comment)
      entry(CommentWithArchive)
    end
  end

  defmodule Api do
    use Ash.Api

    authorization do
      authorize(:by_default)
    end

    resources do
      registry(Registry)
    end
  end

  test "destroying a record archives it" do
    comment =
      Comment
      |> Ash.Changeset.for_create(:create)
      |> Api.create!()

    assert :ok = comment |> Api.destroy!(actor: %{admin: true})

    [archived] = Api.read!(CommentWithArchive)
    assert archived.id == comment.id
    assert archived.archived_at
  end

  test "destroying a record archives any `archive_related` it has configured" do
    post =
      Post
      |> Ash.Changeset.for_create(:create)
      |> Api.create!()

    comment =
      Comment
      |> Ash.Changeset.for_create(:create, %{post_id: post.id})
      |> Api.create!()

    assert :ok = post |> Api.destroy!(actor: %{admin: true})

    [archived] = Api.read!(CommentWithArchive)
    assert archived.id == comment.id
    assert archived.archived_at
  end

  test "destroying a record triggers a cascading archive." do
    author =
      Author
      |> Ash.Changeset.for_create(:create)
      |> Api.create!()

    post =
      Post
      |> Ash.Changeset.for_create(:create, %{author_id: author.id})
      |> Api.create!()

    comment =
      Comment
      |> Ash.Changeset.for_create(:create, %{post_id: post.id})
      |> Api.create!()

    assert :ok = author |> Api.destroy!()

    [archived_post] = Api.read!(PostWithArchive)
    assert archived_post.id == post.id
    assert archived_post.archived_at

    [archived_comment] = Api.read!(CommentWithArchive)
    assert archived_comment.id == comment.id
    assert archived_comment.archived_at
  end
end
