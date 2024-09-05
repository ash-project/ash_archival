defmodule AshArchival.Test.Domain do
  @moduledoc false
  use Ash.Domain

  resources do
    resource(AshArchival.Test.Post)
  end
end
