# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshArchival.Test.ArgumentTest do
  use AshArchival.RepoCase

  alias AshArchival.Test.WithArgsChild
  alias AshArchival.Test.WithArgsParent

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
