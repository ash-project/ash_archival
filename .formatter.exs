# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs/contributors>
#
# SPDX-License-Identifier: MIT

spark_locals_without_parens = [
  archive_related: 1,
  archive_related_arguments: 1,
  archive_related_authorize?: 1,
  attribute: 1,
  attribute_type: 1,
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
