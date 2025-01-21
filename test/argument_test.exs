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
  end
end
