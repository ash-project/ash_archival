defmodule AshStorage.Test.ArgumentTest do
  use AshStorage.RepoCase

  alias AshStorage.Test.WithArgsChild
  alias AshStorage.Test.WithArgsParent

  test "can pass arguments when storing related resources" do
    parent =
      WithArgsParent
      |> Ash.Changeset.for_create(:create)
      |> Ash.create!()

    WithArgsChild
    |> Ash.Changeset.for_create(:create, %{parent_id: parent.id})
    |> Ash.create!()

    parent
    |> Ash.Changeset.for_destroy(:storage, %{arg: "test"})
    |> Ash.destroy!()

    parent =
      WithArgsParent
      |> Ash.Query.for_read(:read)
      |> Ash.read_one!()

    assert parent.arg1 == "test"

    child =
      WithArgsChild
      |> Ash.Query.for_read(:read)
      |> Ash.read_one!()

    assert child.arg1 == "test"
  end
end
