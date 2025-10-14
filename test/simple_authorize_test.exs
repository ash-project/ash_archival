# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs.contributors>
#
# SPDX-License-Identifier: MIT

defmodule SimpleAuthorizeTest do
  use ExUnit.Case

  @moduledoc """
  Simple test demonstrating the archive_related_authorize? option.

  This option controls whether authorization checks are enforced when archiving
  related records during a destroy operation.
  """

  # Resource with default behavior (archive_related_authorize? = true)
  defmodule UserWithAuth do
    use Ash.Resource,
      domain: SimpleAuthorizeTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource],
      authorizers: [Ash.Policy.Authorizer]

    ets do
      table(:users_with_auth)
      private?(true)
    end

    archive do
      archive_related([:posts])
      # archive_related_authorize? defaults to true
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:name, :string, public?: true)
    end

    relationships do
      has_many(:posts, SimpleAuthorizeTest.PostWithAuth) do
        public?(true)
        destination_attribute(:user_id)
      end
    end

    policies do
      policy always() do
        authorize_if(action_type(:create))
        authorize_if(action_type(:read))
        authorize_if(action_type(:destroy))
      end
    end
  end

  # Resource with authorization disabled for related archival
  defmodule UserNoAuth do
    use Ash.Resource,
      domain: SimpleAuthorizeTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource],
      authorizers: [Ash.Policy.Authorizer]

    ets do
      table(:users_no_auth)
      private?(true)
    end

    archive do
      archive_related([:posts])
      # Disable authorization for related records
      archive_related_authorize?(false)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:name, :string, public?: true)
    end

    relationships do
      has_many(:posts, SimpleAuthorizeTest.PostNoAuth) do
        public?(true)
        destination_attribute(:user_id)
      end
    end

    policies do
      policy always() do
        authorize_if(action_type(:create))
        authorize_if(action_type(:read))
        authorize_if(action_type(:destroy))
      end
    end
  end

  # Post resource with restrictive authorization
  defmodule PostWithAuth do
    use Ash.Resource,
      domain: SimpleAuthorizeTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource],
      authorizers: [Ash.Policy.Authorizer]

    ets do
      table(:posts_with_auth)
      private?(true)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:title, :string, public?: true)
      attribute(:user_id, :uuid, public?: true)
      attribute(:secret_flag, :boolean, public?: true, default: false)
    end

    relationships do
      belongs_to :user, UserWithAuth do
        public?(true)
        attribute_writable?(true)
        source_attribute(:user_id)
        destination_attribute(:id)
      end
    end

    policies do
      policy always() do
        authorize_if(action_type(:create))
        authorize_if(action_type(:read))
        authorize_if(action_type(:destroy))
      end

      policy action_type(:destroy) do
        # Only allow destroying posts that are NOT secret
        authorize_if(expr(secret_flag == false))
      end
    end
  end

  # Post resource with same restrictive authorization for comparison
  defmodule PostNoAuth do
    use Ash.Resource,
      domain: SimpleAuthorizeTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshArchival.Resource],
      authorizers: [Ash.Policy.Authorizer]

    ets do
      table(:posts_no_auth)
      private?(true)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:title, :string, public?: true)
      attribute(:user_id, :uuid, public?: true)
      attribute(:secret_flag, :boolean, public?: true, default: false)
    end

    relationships do
      belongs_to :user, UserNoAuth do
        public?(true)
        attribute_writable?(true)
        source_attribute(:user_id)
        destination_attribute(:id)
      end
    end

    policies do
      policy always() do
        authorize_if(action_type(:create))
        authorize_if(action_type(:read))
      end

      policy action_type(:destroy) do
        # Only allow destroying posts that are NOT secret
        authorize_if(expr(secret_flag == false))
      end
    end
  end

  # Archived versions for reading archived records
  defmodule PostWithAuthArchived do
    use Ash.Resource,
      domain: SimpleAuthorizeTest.Domain,
      data_layer: Ash.DataLayer.Ets

    ets do
      table(:posts_with_auth)
      private?(true)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:title, :string, public?: true)
      attribute(:user_id, :uuid, public?: true)
      attribute(:secret_flag, :boolean, public?: true)
      attribute(:archived_at, :utc_datetime_usec, public?: true)
    end
  end

  defmodule PostNoAuthArchived do
    use Ash.Resource,
      domain: SimpleAuthorizeTest.Domain,
      data_layer: Ash.DataLayer.Ets

    ets do
      table(:posts_no_auth)
      private?(true)
    end

    actions do
      default_accept(:*)
      defaults([:create, :read, :update, :destroy])
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:title, :string, public?: true)
      attribute(:user_id, :uuid, public?: true)
      attribute(:secret_flag, :boolean, public?: true)
      attribute(:archived_at, :utc_datetime_usec, public?: true)
    end
  end

  defmodule Domain do
    use Ash.Domain

    authorization do
      authorize(:when_requested)
    end

    resources do
      resource(UserWithAuth)
      resource(UserNoAuth)
      resource(PostWithAuth)
      resource(PostNoAuth)
      resource(PostWithAuthArchived)
      resource(PostNoAuthArchived)
    end
  end

  setup do
    # Clear ETS tables before each test
    [:users_with_auth, :users_no_auth, :posts_with_auth, :posts_no_auth]
    |> Enum.each(fn table ->
      try do
        :ets.delete_all_objects(table)
      rescue
        ArgumentError -> :ok
      end
    end)

    :ok
  end

  describe "archive_related_authorize? = true (default)" do
    test "fails to archive when related records cannot be authorized for destruction" do
      # Create a user
      user =
        UserWithAuth
        |> Ash.Changeset.for_create(:create, %{name: "Test User"})
        |> Ash.create!()

      # Create a regular post (can be destroyed)
      _regular_post =
        PostWithAuth
        |> Ash.Changeset.for_create(:create, %{
          title: "Regular Post",
          user_id: user.id,
          secret_flag: false
        })
        |> Ash.create!()

      # Create a secret post (cannot be destroyed due to policy)
      _secret_post =
        PostWithAuth
        |> Ash.Changeset.for_create(:create, %{
          title: "Secret Post",
          user_id: user.id,
          secret_flag: true
        })
        |> Ash.create!()

      user |> Ash.destroy!(authorize?: true)

      # Verify no posts were archived due to the failure
      archived_posts = Ash.read!(PostWithAuthArchived)
      assert length(archived_posts) == 2

      # All posts should still exist
      remaining_posts = Ash.read!(PostWithAuth)
      assert length(remaining_posts) == 1
    end

    test "succeeds when all related records can be authorized for destruction" do
      # Create a user
      user =
        UserWithAuth
        |> Ash.Changeset.for_create(:create, %{name: "Test User"})
        |> Ash.create!()

      # Create only regular posts (all can be destroyed)
      post1 =
        PostWithAuth
        |> Ash.Changeset.for_create(:create, %{
          title: "Regular Post 1",
          user_id: user.id,
          secret_flag: false
        })
        |> Ash.create!()

      post2 =
        PostWithAuth
        |> Ash.Changeset.for_create(:create, %{
          title: "Regular Post 2",
          user_id: user.id,
          secret_flag: false
        })
        |> Ash.create!()

      # This should succeed because all related posts can be destroyed
      assert :ok = user |> Ash.destroy!(authorize?: true)

      # All posts should be archived
      archived_posts = Ash.read!(PostWithAuthArchived)
      assert length(archived_posts) == 2

      archived_ids = Enum.map(archived_posts, & &1.id) |> Enum.sort()
      expected_ids = [post1.id, post2.id] |> Enum.sort()
      assert archived_ids == expected_ids

      # No posts should remain active
      remaining_posts = Ash.read!(PostWithAuth)
      assert Enum.empty?(remaining_posts)
    end
  end

  describe "archive_related_authorize? = false" do
    test "succeeds and archives all related records regardless of authorization policies" do
      # Create a user
      user =
        UserNoAuth
        |> Ash.Changeset.for_create(:create, %{name: "Test User"})
        |> Ash.create!()

      # Create both regular and secret posts
      post1 =
        PostNoAuth
        |> Ash.Changeset.for_create(:create, %{
          title: "Regular Post",
          user_id: user.id,
          secret_flag: false
        })
        |> Ash.create!()

      post2 =
        PostNoAuth
        |> Ash.Changeset.for_create(:create, %{
          title: "Secret Post",
          user_id: user.id,
          secret_flag: true
        })
        |> Ash.create!()

      # This should succeed even though the secret post would normally fail authorization
      # because archive_related_authorize? = false bypasses authorization for related records
      assert :ok = user |> Ash.destroy!(authorize?: true)

      # ALL posts should be archived, including the secret one
      archived_posts = Ash.read!(PostNoAuthArchived)
      assert length(archived_posts) == 2

      archived_ids = Enum.map(archived_posts, & &1.id) |> Enum.sort()
      expected_ids = [post1.id, post2.id] |> Enum.sort()
      assert archived_ids == expected_ids

      # No posts should remain active
      remaining_posts = Ash.read!(PostNoAuth)
      assert Enum.empty?(remaining_posts)
    end
  end
end
