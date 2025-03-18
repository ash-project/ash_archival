defmodule AshStorage.PostgresTest do
  use AshStorage.RepoCase

  alias AshStorage.Test.Post
  require Ash.Query

  test "unstorage works" do
    assert %Post{} =
             Post
             |> Ash.Changeset.for_create(:create)
             |> Ash.create!()
             |> Ash.Changeset.for_destroy(:destroy)
             |> Ash.destroy!(return_destroyed?: true)
             |> Ash.Changeset.for_update(:unstorage)
             |> Ash.update!()
  end

  test "bulk unstorage works" do
    assert %Ash.BulkResult{records: [%Post{}]} =
             Post
             |> Ash.Changeset.for_create(:create)
             |> Ash.create!()
             |> Ash.Changeset.for_destroy(:destroy)
             |> Ash.destroy!(return_destroyed?: true)
             |> then(fn post ->
               Post
               |> Ash.Query.filter(id == ^post.id)
             end)
             |> Ash.bulk_update!(:unstorage, %{}, return_records?: true)
  end
end
