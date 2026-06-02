<!--
SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs.contributors>

SPDX-License-Identifier: MIT
-->

# Upserts & Identities

Its important to consider identities when using AshArchival _without_ a `base_filter` set up.

If you are using a `base_filter`, then all identities implicitly include that `base_filter` in their
`where` (handled by the data layer).

Take the following identities, for example:

```elixir
identities do
  identity :unique_email, [:email], where: expr(is_nil(archived_at))
  # and
  identity :unique_email, [:email]
end
```

## With `is_nil(archived_at)`

Using this identity allows multiple archived records with the same email, but only one _non-archived_ record per email.
It enables reuse of archived email addresses for new active records, maintaining data integrity by preventing duplicate
active records while preserving archived data.

When you upsert a record using this identity, it will only consider active records.

### Using Ash Postgres?
If using [`Ash Postgres`](https://ash-postgres.hexdocs.pm/readme.html) you will also have to add a corresponding [`identity_wheres_to_sql`](https://ash-postgres.hexdocs.pm/AshPostgres.DataLayer.Info.html#identity_wheres_to_sql/1).

For example:

```elixir
postgres do
...
  identity_wheres_to_sql unique_email: "archived_at IS NULL"
end
```

## Without `is_nil(archived_at)`

This identity configuration enforces strict email uniqueness across all records. Once an email is used, it can't be used
again, even after that record is archived.

When you upsert a record using this identity, it will consider all records.
