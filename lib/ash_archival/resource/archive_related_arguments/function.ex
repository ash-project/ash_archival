# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs/contributors>
#
# SPDX-License-Identifier: MIT

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
