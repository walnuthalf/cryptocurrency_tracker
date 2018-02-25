defmodule CryptocurrencyTracker.Repo.Migrations.CreateRateInfos do
  use Ecto.Migration

  def change do
    create table(:rate_infos) do
      add :symbol, :string
      add :rate, :float
      add :observed_at, :utc_datetime

      timestamps()
    end

  end
end
