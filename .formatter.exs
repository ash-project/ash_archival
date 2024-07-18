spark_locals_without_parens = [
  archive_related: 1,
  attribute: 1,
  base_filter?: 1,
  exclude_destroy_actions: 1,
  exclude_read_actions: 1,
  exclude_upsert_actions: 1
]

[
  inputs: ["{mix,.formatter}.exs", "{config,lib,test}/**/*.{ex,exs}"],
  locals_without_parens: spark_locals_without_parens,
  export: [
    locals_without_parens: spark_locals_without_parens
  ]
]
