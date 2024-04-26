defmodule AshArchival.Resource.Info do
  @moduledoc "Introspection helpers for `AshArchival.Resource`"
  use Spark.InfoGenerator, extension: AshArchival.Resource, sections: [:archive]
end
