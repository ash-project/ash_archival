# SPDX-FileCopyrightText: 2022 ash_archival contributors <https://github.com/ash-project/ash_archival/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshArchival.TestRepo do
  @moduledoc false
  use AshPostgres.Repo,
    otp_app: :ash_archival

  def on_transaction_begin(data) do
    send(self(), data)
  end

  def installed_extensions do
    ["ash-functions"]
  end

  def all_tenants do
    []
  end

  def min_pg_version do
    case System.get_env("PG_VERSION") do
      nil ->
        %Version{major: 16, minor: 0, patch: 0}

      version ->
        # CI passes a major version only, e.g. "16"; `Version` wants "16.0.0".
        version
        |> String.split(".")
        |> Enum.concat(["0", "0"])
        |> Enum.take(3)
        |> Enum.join(".")
        |> Version.parse!()
    end
  end
end
