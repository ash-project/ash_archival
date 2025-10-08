# SPDX-FileCopyrightText: 2020 Zach Daniel
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
