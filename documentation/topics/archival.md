# Archival

## Extension

This extension modifies a resource in the following ways.

1. Adds a private `archived_at` `utc_datetime_usec` attribute.
2. Adds a base filter to the resource, for `is_nil(archived_at)`
3. Marks all destroy actions as `soft?`, turning them into updates
4. Adds a change to all destroy actions that sets `archived_at` to the current timestamp
5. Adds a change that will iteratively load and destroy anything configured in `d:AshArchival.Resource.archive|archive_related` 
## Considerations

### Performance of Archive Related

`d:AshArchival.Resource.archive|archive_related` is a simple iterative process. It is performed synchronously, and therefore is not suited for large cardinality relationships. Eventually, when bulk actions are supported, this can be migrated to use that. If you need to archive a very large amount of related things, you will need to write a custom change to handle this.

## More

See the [Unarchiving guide](/documentation/topics/unarchiving.md) For more.