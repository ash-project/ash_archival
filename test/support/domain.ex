defmodule AshStorage.Test.Domain do
  @moduledoc false
  use Ash.Domain

  resources do
    resource(AshStorage.Test.Post)
    resource(AshStorage.Test.WithArgsParent)
    resource(AshStorage.Test.WithArgsChild)
  end
end
