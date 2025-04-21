defmodule AshArchival.Test.Post.Archival do
  use Spark.Dsl.Fragment,
    of: Ash.Resource,
    extensions: [AshArchival.Resource]

  archive do
    exclude_read_actions :all_posts
  end
end
