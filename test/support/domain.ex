# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshArchival.Test.Domain do
  @moduledoc false
  use Ash.Domain

  resources do
    resource(AshArchival.Test.Post)
    resource(AshArchival.Test.WithArgsParent)
    resource(AshArchival.Test.WithArgsChild)
  end
end
