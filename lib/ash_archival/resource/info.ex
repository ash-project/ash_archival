defmodule AshArchival.Resource.Info do
  @moduledoc "Introspection helpers for `AshArchival.Resource`"
  def archive_related(resource) do
    Spark.Dsl.Extension.get_opt(resource, [:archive], :archive_related, [])
  end
end
