defmodule AshArchival.ArchiveRelatedArguments.Function do
  @moduledoc false

  @behaviour AshArchival.ArchiveRelatedArguments

  @impl true
  def arguments(arguments, relationship, [{:fun, {m, f, a}}]) do
    apply(m, f, [arguments, relationship, a])
  end

  @impl true
  def arguments(arguments, relationship, [{:fun, fun}]) do
    fun.(arguments, relationship)
  end
end
