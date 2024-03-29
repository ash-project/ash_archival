# Un-archiving

At the moment, there is no way to unarchive an entry with a simple action on that resource. However, if you define a simple resource that uses the same storage under the hood (e.g same database table), but does _not_ use the archival extension. You could then fabricate unarchival with something like this (this is not vetted, it is a pseudo-code example):

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
    |> Ash.read_one()
    |> case do
      {:ok, nil} ->
        # not found error
      {:ok, found} ->
        # unarchive
        found
        |> Ash.Changeset.for_update(:update, %{archived_at: nil})
        |> Ash.update!()

      {:ok, Ash.get!(changeset.resource, id)}
    end
  end)
end
```
