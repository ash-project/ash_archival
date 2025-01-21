defmodule AshArchival.ArchiveRelatedArguments do
  @moduledoc """
  The behaviour for specifiying arguments for related resources
  """
  @callback arguments(
              original_arguments :: :map,
              relationship :: :atom,
              opts :: Keyword.t()
            ) ::
              :map
end
