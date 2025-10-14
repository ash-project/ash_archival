# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshArchival.Resource.Info do
  @moduledoc "Introspection helpers for `AshArchival.Resource`"
  use Spark.InfoGenerator, extension: AshArchival.Resource, sections: [:archive]
end
