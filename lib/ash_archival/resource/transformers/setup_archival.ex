defmodule AshArchival.Resource.Transformers.SetupArchival do
  @moduledoc false
  # Sets up the required resource structure for archival
  use Spark.Dsl.Transformer

  @after_transformers [
    Ash.Resource.Transformers.ValidatePrimaryActions
  ]

  @before_transformers [
    Ash.Resource.Transformers.DefaultAccept,
    Ash.Resource.Transformers.SetTypes
  ]

  alias Spark.Dsl.Transformer

  def transform(dsl_state) do
    if Transformer.get_persisted(dsl_state, :embedded?, false) do
      {:ok, dsl_state}
    else
      dsl_state
      |> add_archived_at()
      |> update_destroy_actions()
      |> add_base_filter()
      |> add_base_filter_sql()
    end
  end

  def after?(transformer) when transformer in @after_transformers, do: true
  def after?(_), do: false

  def before?(transformer) when transformer in @before_transformers, do: true
  def before?(_), do: false

  defp add_archived_at(dsl_state) do
    with {:ok, archived_at} <-
           Transformer.build_entity(Ash.Resource.Dsl, [:attributes], :attribute,
             name: :archived_at,
             type: :utc_datetime_usec,
             private?: true,
             allow_nil?: true
           ) do
      {:ok, Transformer.add_entity(dsl_state, [:attributes], archived_at)}
    end
  end

  defp update_destroy_actions({:ok, dsl_state}) do
    dsl_state
    |> Transformer.get_entities([:actions])
    |> Enum.filter(&(&1.type == :destroy))
    |> Enum.reduce({:ok, dsl_state}, fn destroy_action, {:ok, dsl_state} ->
      with {:ok, set_archived_at} <-
             Transformer.build_entity(Ash.Resource.Dsl, [:actions, :destroy], :change,
               change:
                 Ash.Resource.Change.Builtins.set_attribute(:archived_at, &DateTime.utc_now/0)
             ),
           {:ok, archive_related} <-
             Transformer.build_entity(Ash.Resource.Dsl, [:actions, :destroy], :change,
               change: {AshArchival.Resource.Changes.ArchiveRelated, []}
             ) do
        new_action = %{
          destroy_action
          | soft?: true,
            changes: [set_archived_at, archive_related | destroy_action.changes]
        }

        {:ok,
         Transformer.replace_entity(
           dsl_state,
           [:actions],
           new_action,
           &(&1.name == destroy_action.name)
         )}
      end
    end)
  end

  defp update_destroy_actions({:error, error}), do: {:error, error}

  defp add_base_filter({:ok, dsl_state}) do
    case Transformer.get_option(dsl_state, [:resource], :base_filter) do
      nil ->
        {:ok, Transformer.set_option(dsl_state, [:resource], :base_filter, is_nil: :archived_at)}

      value ->
        {:ok,
         Transformer.set_option(dsl_state, [:resource], :base_filter,
           and: [[is_nil: :archived_at], value]
         )}
    end
  end

  defp add_base_filter({:error, error}) do
    {:error, error}
  end

  defp add_base_filter_sql({:ok, dsl_state}) do
    case Transformer.get_option(dsl_state, [:postgres], :base_filter_sql) do
      nil ->
        {:ok,
         Transformer.set_option(dsl_state, [:postgres], :base_filter_sql, "archived_at IS NULL")}

      value ->
        {:ok,
         Transformer.set_option(
           dsl_state,
           [:postgres],
           :base_filter_sql,
           "archived_at IS NULL and (#{value})"
         )}
    end
  end

  defp add_base_filter_sql({:error, error}) do
    {:error, error}
  end
end
