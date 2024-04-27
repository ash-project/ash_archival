# Un-archiving

Un-archiving can be accomplished by creating a read action that is skipped, using `exclude_read_actions`. Then, you can create an update action that sets that attribute to `nil`. For example:

```elixir
archive do
  ...
  exclude_read_actions :archived
end

actions do
  read :archived do
    filter expr(not is_nil(archived_at))
  end

  update :unarchive do
    update set_attribute(:archived_at, nil)
  end
end
```

You could then do something like this:

```elixir
Resource
|> Ash.get!(id, action: :archived)
|> Ash.Changeset.for_update(:unarchive, %{)
|> Ash.update!()
```

More idiomatically, you would define a code interfaceon the domain, and call that:

```elixir
# to unarchive by `id`
Resource
|> Ash.Query.for_read(:archived, %{})
|> Ash.Query.filter(id == ^id)
|> Domain.unarchive!()
```
