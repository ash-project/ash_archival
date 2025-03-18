defmodule AshStorage.Resource do
  @storage %Spark.Dsl.Section{
    name: :storage,
    describe: "A section for configuring how storage is configured for a resource.",
    schema: [
      attribute: [
        type: :atom,
        default: :stored_at,
        doc: "The attribute in which to store the storage flag (the current datetime)."
      ],
      attribute_type: [
        type: :atom,
        default: :utc_datetime_usec,
        doc: "The attribute type."
      ],
      base_filter?: [
        type: :atom,
        default: false,
        doc: "Whether or not a base filter exists that applies the `is_nil(stored_at)` rule."
      ],
      exclude_read_actions: [
        type: {:wrap_list, :atom},
        default: [],
        doc: """
        A read action or actions that should show stored items. They will not get the automatic `is_nil(stored_at)` filter.
        """
      ],
      exclude_upsert_actions: [
        type: {:wrap_list, :atom},
        default: [],
        deprecated:
          "Upserts are handled according to the upsert identity. See the upserts guide for more.",
        doc: """
        This option is deprecated as it no longer has any effect. Upserts are handled according to the upsert identity. See the upserts guide for more.
        """
      ],
      exclude_destroy_actions: [
        type: {:wrap_list, :atom},
        default: [],
        doc: """
        A destroy action or actions that should *not* store, but instead be left alone. This allows for having a destroy *or* store pattern.
        """
      ],
      storage_related: [
        type: {:list, :atom},
        default: [],
        doc: """
        A list of relationships that should have all related items stored when this is stored. Notifications are not sent for this operation.
        """
      ],
      storage_related_arguments: [
        type:
          {:spark_function_behaviour, AshStorage.StorageRelatedArguments,
           {AshStorage.StorageRelatedArguments.Function, 2}},
        doc: """
        A function to allow passing along some of the arguments to related resources when storing them.
        """
      ]
    ]
  }

  @moduledoc """
  Configures a resource to be stored instead of destroyed for all destroy actions.

  For more information, see [the getting started guide](/documentation/tutorials/get-started-with-ash-storage.md)
  """

  use Spark.Dsl.Extension,
    sections: [@storage],
    transformers: [AshStorage.Resource.Transformers.SetupStorage]
end
