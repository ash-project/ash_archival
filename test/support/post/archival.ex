# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshArchival.Test.Post.Archival do
  @moduledoc false
  use Spark.Dsl.Fragment,
    of: Ash.Resource,
    extensions: [AshArchival.Resource]

  archive do
    exclude_read_actions :all_posts
  end
end
