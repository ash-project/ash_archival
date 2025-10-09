# SPDX-FileCopyrightText: 2020 Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule AshArchival.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias AshArchival.TestRepo

      import Ecto
      import Ecto.Query
      import AshArchival.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Sandbox.checkout(AshArchival.TestRepo)

    unless tags[:async] do
      Sandbox.mode(AshArchival.TestRepo, {:shared, self()})
    end

    :ok
  end
end
