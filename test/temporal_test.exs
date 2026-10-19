# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule TemporalTest do
  use ExUnit.Case

  require Ash.Query

  defmodule Author do
    use Ash.Resource,
      domain: TemporalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource]

    ets do
      private?(true)
    end

    temporal do
      strategy(:context)
      attribute(:valid_at)
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
      has_many(:posts, TemporalTest.Post) do
        public?(true)
        temporal_keys({:valid_at, :valid_at})
      end
    end
  end

  defmodule Post do
    use Ash.Resource,
      domain: TemporalTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource]

    ets do
      private?(true)
    end

    temporal do
      strategy(:context)
      attribute(:valid_at)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
    end

    relationships do
      belongs_to(:author, Author) do
        public?(true)
        attribute_writable?(true)
        temporal_keys({:valid_at, :valid_at})
      end
    end
  end

  defmodule Domain do
    use Ash.Domain

    resources do
      resource(Author)
      resource(Post)
    end
  end

  @t1 ~U[2026-01-01 00:00:00.000000Z]
  @t2 ~U[2026-02-01 00:00:00.000000Z]
  @t3 ~U[2026-03-01 00:00:00.000000Z]

  setup do
    on_exit(fn ->
      Ash.DataLayer.Ets.stop(Author)
      Ash.DataLayer.Ets.stop(Post)
    end)

    author = Ash.create!(Author, %{}, as_of: @t1)
    post = Ash.create!(Post, %{author_id: author.id}, as_of: @t1)

    %{author: author, post: post}
  end

  defp exists?(resource, id, as_of) do
    resource
    |> Ash.Query.filter(id == ^id)
    |> Ash.exists?(as_of: as_of)
  end

  test "destroying a record archives it as of the destroy", %{post: post} do
    Ash.destroy!(post, as_of: @t2)

    assert exists?(Post, post.id, @t1)
    refute exists?(Post, post.id, @t2)
  end

  test "destroying a record over a range archives it over that range", %{post: post} do
    Ash.destroy!(post, as_of: %Ash.Range{lower: @t2, upper: @t3, bounds: :"[)"})

    assert exists?(Post, post.id, @t1)
    refute exists?(Post, post.id, @t2)
    assert exists?(Post, post.id, @t3)
  end

  test "destroying a record archives its archive_related as of the destroy", %{
    author: author,
    post: post
  } do
    Ash.destroy!(author, as_of: @t2)

    assert exists?(Author, author.id, @t1)
    refute exists?(Author, author.id, @t2)

    assert exists?(Post, post.id, @t1)
    refute exists?(Post, post.id, @t2)
  end

  test "destroying a record over a range archives its archive_related over that range", %{
    author: author,
    post: post
  } do
    Ash.destroy!(author, as_of: %Ash.Range{lower: @t2, upper: @t3, bounds: :"[)"})

    refute exists?(Author, author.id, @t2)
    assert exists?(Author, author.id, @t3)

    assert exists?(Post, post.id, @t1)
    refute exists?(Post, post.id, @t2)
    assert exists?(Post, post.id, @t3)
  end
end
