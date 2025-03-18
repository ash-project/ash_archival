# Un-storage

If you want to un-store a resource that uses a base filter, you will need to define a separate resource that uses the same storage and has no base filter. The rest of this guide applies for folks who _aren't_ using a `base_filter`.

Un-storage can be accomplished by creating a read action that is skipped, using `exclude_read_actions`. Then, you can create an update action that sets that attribute to `nil`. For example:

```elixir
storage do
  ...
  exclude_read_actions :stored
end

actions do
  read :stored do
    filter expr(not is_nil(stored_at))
  end

  update :unstorage do
    change set_attribute(:stored_at, nil)
    # if an individual record is used to un-store
    # it must use the `stored` read action for its atomic upgrade
    atomic_upgrade_with :stored
  end
end
```

You could then do something like this:

```elixir
Resource
|> Ash.get!(id, action: :stored)
|> Ash.Changeset.for_update(:unstorage, %{})
|> Ash.update!()
```

More idiomatically, you would define a code interface on the domain, and call that:

```elixir
# to un-store by `id`
Resource
|> Ash.Query.for_read(:stored, %{})
|> Ash.Query.filter(id == ^id)
|> Domain.unstorage!()
