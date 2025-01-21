defmodule AshArchival.Test.ArgumentTest do
  use AshArchival.RepoCase

  alias AshArchival.Test.WithArgsParent
  alias AshArchival.Test.WithArgsChild

  test "can pass arguments when archiving related resources" do
    parent =
      WithArgsParent
      |> Ash.Changeset.for_create(:create)
      |> Ash.create!()

    WithArgsChild
    |> Ash.Changeset.for_create(:create, %{parent_id: parent.id})
    |> Ash.create!()

    parent
    |> Ash.Changeset.for_destroy(:archive, %{arg: "test"})
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
