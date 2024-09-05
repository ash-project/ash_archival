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

  def min_pg_version do
    case System.get_env("PG_VERSION") do
      nil -> %Version{major: 16, minor: 0, patch: 0}
      version -> Version.parse!(version)
    end
  end
end
