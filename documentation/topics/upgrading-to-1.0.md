## Upgrading to 1.0

## Implementation changed from base_filter to preparations

Before 1.0 of this library, a `base_filter` was added to the resource to hide stored items. To retain the old behavior (which includes database structure),
add the `base_filter` and `base_filter_sql` yourself. Additionally, set `base_filter? true` in the `storage` block to ensure that we don't apply the filter twice.

See the [getting started guide](documentation/tutorials/get-started-with-ash-storage.md) for more on base filters.
