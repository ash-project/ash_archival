# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshArchival.ArchiveRelatedArguments do
  @moduledoc """
  The behaviour for specifiying arguments for related resources
  """
  @callback arguments(
              original_arguments :: map(),
              relationship :: atom(),
              opts :: Keyword.t()
            ) :: map()
end
