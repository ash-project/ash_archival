defmodule AshArchival.PostgresTest do
  use AshArchival.RepoCase

  alias AshArchival.Test.Post
  require Ash.Query

  test "unarchival works" do
    assert %Post{} =
             Post
             |> Ash.Changeset.for_create(:create)
             |> Ash.create!()
             |> Ash.Changeset.for_destroy(:destroy)
             |> Ash.destroy!(return_destroyed?: true)
             |> Ash.Changeset.for_update(:unarchive)
             |> Ash.update!()
  end

  test "bulk unarchival works" do
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
             |> Ash.bulk_update!(:unarchive, %{}, return_records?: true)
  end
end
