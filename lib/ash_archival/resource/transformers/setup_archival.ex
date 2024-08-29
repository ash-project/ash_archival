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
      |> add_preparation()
    end
  end

  def after?(transformer) when transformer in @after_transformers, do: true
  def after?(_), do: false

  def before?(transformer) when transformer in @before_transformers, do: true
  def before?(_), do: false

  defp add_archived_at(dsl_state) do
    attribute = AshArchival.Resource.Info.archive_attribute!(dsl_state)
    attribute_type = AshArchival.Resource.Info.archive_attribute_type!(dsl_state)

    Ash.Resource.Builder.add_new_attribute(dsl_state, attribute, attribute_type,
      public?: false,
      allow_nil?: true
    )
  end

  defp update_destroy_actions({:ok, dsl_state}) do
    attribute = AshArchival.Resource.Info.archive_attribute!(dsl_state)

    exclude_destroy_actions =
      AshArchival.Resource.Info.archive_exclude_destroy_actions!(dsl_state)

    dsl_state
    |> Transformer.get_entities([:actions])
    |> Enum.filter(&(&1.type == :destroy && &1.name not in exclude_destroy_actions))
    |> Enum.reduce({:ok, dsl_state}, fn destroy_action, {:ok, dsl_state} ->
      with {:ok, set_archived_at} <-
             Transformer.build_entity(Ash.Resource.Dsl, [:actions, :destroy], :change,
               change: Ash.Resource.Change.Builtins.set_attribute(attribute, &DateTime.utc_now/0)
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

  defp add_preparation({:ok, dsl_state}) do
    Ash.Resource.Builder.add_preparation(
      dsl_state,
      {AshArchival.Resource.Preparations.FilterArchived, []}
    )
  end
end
