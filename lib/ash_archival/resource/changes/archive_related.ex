defmodule AshArchival.Resource.Changes.ArchiveRelated do
  @moduledoc false
  use Ash.Resource.Change
  require Ash.Query

  def change(changeset, _, context) do
    context =
      case AshArchival.Resource.Info.archive_archive_related_authorize?(changeset.resource) do
        true ->
          %{context | authorize?: context.authorize?}

        _ ->
          %{context | authorize?: false}
      end

    Ash.Changeset.after_action(changeset, fn changeset, result ->
      archive_related(
        [result],
        changeset.resource,
        changeset.domain,
        changeset.arguments,
        context
      )

      {:ok, result}
    end)
  end

  def atomic(_changeset, _, _) do
    :ok
  end

  def after_atomic(changeset, _, record, context) do
    archive_related([record], changeset.resource, changeset.domain, changeset.arguments, context)

    :ok
  end

  def after_batch([{first_changeset, _} | _] = changesets_and_results, _opts, context) do
    records =
      Enum.map(changesets_and_results, &elem(&1, 1))

    archive_related(
      records,
      first_changeset.resource,
      first_changeset.domain,
      first_changeset.arguments,
      context
    )

    Enum.map(records, fn result ->
      {:ok, result}
    end)
  end

  def batch_callbacks?([], _, _), do: false

  def batch_callbacks?([%{resource: resource} | _], _, _) do
    resource
    |> AshArchival.Resource.Info.archive_archive_related!()
    |> Enum.any?()
  end

  def batch_callbacks?(%{resource: resource}, _, _) do
    resource
    |> AshArchival.Resource.Info.archive_archive_related!()
    |> Enum.any?()
  end

  defp archive_related([], _, _, _, _) do
    :ok
  end

  defp archive_related(data, resource, domain, arguments, context) do
    opts =
      context
      |> Ash.Context.to_opts(
        domain: domain,
        return_errors?: true,
        strategy: [:stream, :atomic, :atomic_batches]
      )

    archive_related =
      AshArchival.Resource.Info.archive_archive_related!(resource)

    Enum.each(archive_related, fn relationship ->
      relationship = Ash.Resource.Info.relationship(resource, relationship)

      destroy_action =
        Ash.Resource.Info.primary_action!(relationship.destination, :destroy).name

      arguments =
        case AshArchival.Resource.Info.archive_archive_related_arguments(resource) do
          {:ok, {module, options}} -> module.arguments(arguments, relationship, options)
          _ -> %{}
        end

      context =
        opts[:context]
        |> Kernel.||(%{})
        |> Map.put(:ash_archival, true)
        |> Ash.Helpers.deep_merge_maps(relationship.context || %{})

      case related_query(data, relationship, opts) do
        {:ok, query} ->
          Ash.bulk_destroy!(
            query,
            destroy_action,
            arguments,
            Keyword.put(opts, :context, context)
          )

        :error ->
          data
          |> List.wrap()
          |> Ash.load!(
            [
              {relationship.name,
               Ash.Query.set_context(relationship.destination, %{ash_archival: true})}
            ],
            opts
          )
          |> Enum.flat_map(fn record ->
            record
            |> Map.get(relationship.name)
            |> List.wrap()
          end)
          |> Ash.bulk_destroy!(
            destroy_action,
            %{},
            Keyword.put(opts, :context, context)
          )
      end
    end)
  end

  # An advanced optimization to be made here is to use lateral join context,
  # allowing us not to fetch this relationship in the case that data layers
  # support lateral joining. Not sure if this would "just work" to be paired
  # with `update_query` or if we would need a separate callback.
  defp related_query(_records, %{type: :many_to_many}, _opts) do
    :error
  end

  defp related_query(records, relationship, opts) do
    if Ash.Actions.Read.Relationships.has_parent_expr?(relationship) do
      :error
    else
      {:ok,
       Ash.Actions.Read.Relationships.related_query(
         relationship.name,
         records,
         Ash.Query.new(relationship.destination),
         Ash.Query.new(relationship.source)
         |> Ash.Query.set_context(%{
           private: %{
             actor: opts[:actor],
             tenant: opts[:tenant],
             authorize?: opts[:authorize?],
             tracer: opts[:tracer]
           }
         })
       )
       |> elem(1)
       |> filter_by_keys(relationship, records)
       |> Ash.Query.set_context(%{ash_archival: true})
       |> Ash.Query.set_context(relationship.context || %{})
       |> Ash.Query.set_tenant(opts[:tenant])}
    end
  end

  defp filter_by_keys(query, %{no_attributes?: true}, _records) do
    query
  end

  defp filter_by_keys(
         query,
         %{source_attribute: source_attribute, destination_attribute: destination_attribute},
         records
       ) do
    source_values = Enum.map(records, &Map.get(&1, source_attribute))

    Ash.Query.filter(query, ^ref(destination_attribute) in ^source_values)
  end
end
