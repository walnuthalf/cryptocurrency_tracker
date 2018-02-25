defmodule CryptocurrencyTracker.Currencies.RateInfo do
  use Ecto.Schema
  import Ecto.Changeset
  alias CryptocurrencyTracker.Currencies.RateInfo


  schema "rate_infos" do
    field :observed_at, :utc_datetime
    field :rate, :float
    field :symbol, :string

    timestamps()
  end

  @doc false
  def changeset(%RateInfo{} = rate_info, attrs) do
    rate_info
    |> cast(attrs, [:symbol, :rate, :observed_at])
    |> validate_required([:symbol, :rate, :observed_at])
  end
end
