defmodule AshStorage.RepoCase do
  @moduledoc false
  use ExUnit.CaseTemplate

  alias Ecto.Adapters.SQL.Sandbox

  using do
    quote do
      alias AshStorage.TestRepo

      import Ecto
      import Ecto.Query
      import AshStorage.RepoCase

      # and any other stuff
    end
  end

  setup tags do
    :ok = Sandbox.checkout(AshStorage.TestRepo)

    unless tags[:async] do
      Sandbox.mode(AshStorage.TestRepo, {:shared, self()})
    end

    :ok
  end
end
