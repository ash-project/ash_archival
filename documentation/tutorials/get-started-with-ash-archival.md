# Get Started with AshArchival

## Installation

First, add the dependency to your `mix.exs` file

```elixir
{:ash_archival, "~> 2.0.1"}
```

and add `:ash_archival` to your `.formatter.exs`

```elixir
import_deps: [..., :ash_archival]
```

## Adding to a resource

To add archival to a resource, add the extension to the resource:

```elixir
use Ash.Resource,
  extensions: [..., AshArchival.Resource]
```

And thats it! Now, when you destroy a record, it will be archived instead, using an `archived_at` attribute.

See [How Does Ash Archival Work?](/documentation/topics/how-does-ash-archival-work.md) for what modifications are made to a resource, and read on for info on the tradeoffs of leveraging `d:Ash.Resource.Dsl.resource.base_filter`.

## Base Filter

Using a `d:Ash.Resource.Dsl.resource.base_filter` for your `archived_at` field has a lot of benefits if you are using `ash_postgres`, but comes with one major drawback, which is that it is not possible to exclude certain read actions from archival. If you wish to use a base filter, you will need to create a separate resource to read from the archived items. We may introduce a way to bypass the base filter at some point in the future.

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

Add `base_filter? true` to the `archive` configuration of your resource to tell it that it doesn't need to add the filter itself.

### Benefits of base_filter

1. unique indexes will exclude archived items
2. custom indexes will exclude archived items
3. check constraints will not be applied to archived items

If you want these benefits, add the appropriate `base_filter`.

## archive_related_authorize?

The `archive_related_authorize?` option controls whether authorization checks are enforced when archiving related records during a destroy operation.

```elixir
defmodule MyApp.Post do
  use Ash.Resource,
    extensions: [AshArchival.Resource]

  archive do
    archive_related([:comments])
    archive_related_authorize?(false)  # Recommended: bypass authorization for related records
  end
end
```

**Default behavior (`archive_related_authorize?: true`):**
- Authorization policies are enforced when archiving related records
- If the actor lacks permission to read or destroy a record, that record will be *skipped*
- Only related records the actor is authorized to destroy will be archived

**Recommended behavior (`archive_related_authorize?: false`):**
- Authorization checks are bypassed when archiving related records
- All related records are archived regardless of the actor's permissions on those specific records
- The operation succeeds even if the actor wouldn't normally be able to destroy some related records

**Why set it to false?**

You typically want to set `archive_related_authorize?` to `false` because when you archive a parent record, you usually want ALL related records to be archived together, regardless of individual permissions. You typically just want to authorize the actor to archive the record in question, not all descendents.

## More

See the [Unarchiving guide](/documentation/topics/unarchiving.md) For more.
