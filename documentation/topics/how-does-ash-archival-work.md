<!--
SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs.contributors>

SPDX-License-Identifier: MIT
-->

# How does Archival Work?

We make modifications to the resource to enable soft deletes. Here's a breakdown of what the extension does:

## Resource Modifications

1. Adds a private `archived_at` `utc_datetime_usec` attribute.
2. Adds a preparation that filters each action for `is_nil(archived_at)` (except for excluded actions, or if you have `base_filter?` set to `true`).
3. Marks all destroy actions as `soft?`, turning them into updates (except for excluded actions)
4. Adds a change to all destroy actions that sets `archived_at` to the current timestamp
5. Adds a change that will iteratively load and destroy anything configured in `d:AshArchival.Resource.archive|archive_related`
