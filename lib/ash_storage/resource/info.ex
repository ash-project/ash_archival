defmodule AshStorage.Resource.Info do
  @moduledoc "Introspection helpers for `AshStorage.Resource`"
  use Spark.InfoGenerator, extension: AshStorage.Resource, sections: [:storage]
end
