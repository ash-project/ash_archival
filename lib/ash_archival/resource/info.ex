# SPDX-FileCopyrightText: 2020 Zach Daniel
#
# SPDX-License-Identifier: MIT

defmodule AshArchival.Resource.Info do
  @moduledoc "Introspection helpers for `AshArchival.Resource`"
  use Spark.InfoGenerator, extension: AshArchival.Resource, sections: [:archive]
end
