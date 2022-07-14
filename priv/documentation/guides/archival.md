# Archival

## Extension

This extension modifies a resource in the following ways.

1. Adds a private `archived_at` `utc_datetime_usec` attribute.
2. Adds a base filter to the resource, for `is_nil(archived_at)`
3. Marks all destroy actions as `soft?`, turning them into updates
4. Adds a change to all destroy actions that sets `archived_at` to the current timestamp
5. Adds a change that will iteratively load and destroy anything configured in {{link:ash_archival:dsl:resource-archival/archive_related}}

## Considerations

### Performance of Archive Related

{{link:ash_archival:dsl:resource-archival/archive_related}} is a simple iterative process. It is performed synchronously, and therefore is not suited for large cardinality relationships. Eventually, when bulk actions are supported, this can be migrated to use that. If you need to archive a very large amount of related things, you will need to write a custom change to handle this.

### Un-archiving

At the moment, there is no way to unarchive an entry with a simple action on that resource. However, if you define a simple resource that uses the same storage under the hood (e.g same database table), but does *not* use the archival extension. You could then fabricate unarchival with something like this (this is not vetted, it is a pseudo-code example):

```elixir
# on the archived resource
# we model it as a create because there is no input record
create :unarchive do
  manual? true
  argument :id, :uuid do
    allow_nil? false
  end

  change Unarchive
end
```

with an `Unarchive` change like this

```elixir
def change(changeset, _, _) do
  # no data yet, so match on result being `nil`
  Ash.Changeset.after_action(changeset, fn changeset, nil -> 
    id = Ash.Changeset.get_argument(changeset, :id)

    ResourceWithoutArchival
    |> Ash.Query.filter(id == ^id)
    |> Api.read_one()
    |> case do
      {:ok, nil} ->
        # not found error
      {:ok, found} ->
        # unarchive
        found
        |> Ash.Changeset.for_update(:update, %{archived_at: nil})
        |> Api.update!()

      {:ok, Api.get!(changeset.resource, id)}
    end
  end)
end
```
