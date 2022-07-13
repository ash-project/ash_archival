defmodule ArchivalTest do
  use ExUnit.Case

  defmodule Post do
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource]

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
      has_many(:comments, ArchivalTest.Comment)
    end
  end

  defmodule Comment do
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource]

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

    relationships do
      belongs_to(:post, Post)
    end
  end

  defmodule PostWithArchive do
    use Ash.Resource,
      data_layer: Ash.DataLayer.Ets

    ets do
      private?(true)
      table(:posts)
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
      entry(Post)
      entry(PostWithArchive)
      entry(Comment)
      entry(CommentWithArchive)
    end
  end

  defmodule Api do
    use Ash.Api

    resources do
      registry(Registry)
    end
  end

  test "destroying a record archives it" do
    post =
      Post
      |> Ash.Changeset.for_create(:create)
      |> Api.create!()

    assert :ok =
             post
             |> Api.destroy!()

    [archived] = Api.read!(PostWithArchive)

    assert archived.id == post.id
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

    assert :ok =
             post
             |> Api.destroy!()

    [archived] = Api.read!(CommentWithArchive)

    assert archived.id == comment.id
    assert archived.archived_at
  end
end
