# Get Started with AshStorage

## Installation

First, add the dependency to your `mix.exs` file

```elixir
{:ash_storage, "~> 1.1.1"}
```

and add `:ash_storage` to your `.formatter.exs`

```elixir
import_deps: [..., :ash_storage]
```

## Adding to a resource

To add storage to a resource, add the extension to the resource:

```elixir
use Ash.Resource,
  extensions: [..., AshStorage.Resource]
```

And thats it! Now, when you destroy a record, it will be stored instead, using a `stored_at` attribute.

See [How Does Ash Storage Work?](/documentation/topics/how-does-ash-storage-work.md) for what modifications are made to a resource, and read on for info on the tradeoffs of leveraging `d:Ash.Resource.Dsl.resource.base_filter`.

## Base Filter

Using a `d:Ash.Resource.Dsl.resource.base_filter` for your `stored_at` field has a lot of benefits if you are using `ash_postgres`, but comes with one major drawback, which is that it is not possible to exclude certain read actions from storage. If you wish to use a base filter, you will need to create a separate resource to read from the stored items. We may introduce a way to bypass the base filter at some point in the future.

To add a `base_filter` and `base_filter_sql` to your resource:

```elixir
resource do
  base_filter expr(is_nil(stored_at))
end

postgres do
  ...
  base_filter_sql "(stored_at IS NULL)"
end
```

Add `base_filter? true` to the `storage` configuration of your resource to tell it that it doesn't need to add the filter itself.

### Benefits of base_filter

1. unique indexes will exclude stored items
2. custom indexes will exclude stored items
3. check constraints will not be applied to stored items

If you want these benefits, add the appropriate `base_filter`.

## More

See the [Unstorage guide](/documentation/topics/unstorage.md) For more.
