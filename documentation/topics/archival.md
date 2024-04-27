# Archival

## Extension

This extension modifies a resource in the following ways.

1. Adds a private `archived_at` `utc_datetime_usec` attribute.
2. Adds a preparation that filters each action for `is_nil(archived_at)` (except for excluded actions)
3. Marks all destroy actions as `soft?`, turning them into updates (except for excluded actions)
4. Adds a change to all destroy actions that sets `archived_at` to the current timestamp
5. Adds a change that will iteratively load and destroy anything configured in `d:AshArchival.Resource.archive|archive_related`

## Upgrading from < 1.0

Before 1.0 of this library, a `base_filter` was added to the resource to hide archived items. To retain the old behavior (which includes database structure),
add the `base_filter` and `base_filter_sql` yourself.

## Base Filter

Using a `base_filter` for your `archived_at` field has a lot of benefits if you are using `ash_postgres`, but comes with one major drawback, which is that it is not possible to exclude certain read actions from archival. If you wish to use a base filter, you will need to create a separate resource to read from the archived items. We may introduce a way to bypass the base filter at some point in the future.

To add a `base_filter` and `base_filter_sql` to your resource:

```elixir
resource do
  base_filter expr(is_nil(archived_at))
end

postgres do
  ...
  base_filter_sql "(archived_at IS NULL)"
end
```

### Benefits of base_filter

1. unique indexes will exclude archived items
2. custom indexes will exclude archived items
3. check constraints will not be applied to archived items

If you want these benefits, add the appropriate `base_filter`.

## More

See the [Unarchiving guide](/documentation/topics/unarchiving.md) For more.
