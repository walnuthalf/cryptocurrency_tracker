defmodule CryptocurrencyTracker.Currencies do
  @moduledoc """
  The Currencies context.
  """

  import Ecto.Query, warn: false
  alias CryptocurrencyTracker.Repo

  alias CryptocurrencyTracker.Currencies.RateInfo

  def get_earliest_rate_info(symbol) do
    query = from r in RateInfo, 
      where: r.symbol == ^symbol,
      order_by: [asc: r.observed_at],
      limit: 1
    case Repo.all(query) do
      [rate_info] -> {:ok, rate_info}
      [] -> :no_results 
    end
  end 

  def get_rate_infos_at_time(symbol, at_time) do
    query = from r in RateInfo, 
      where: (r.observed_at < ^at_time) and (r.symbol == ^symbol),
      order_by: [desc: r.observed_at],
      limit: 1

    case Repo.all(query) do
      [rate_info] -> {:ok, rate_info}
      [] -> get_earliest_rate_info(symbol)
    end
  end

  @doc """
  Returns the list of rate_infos.

  ## Examples

      iex> list_rate_infos()
      [%RateInfo{}, ...]

  """
  def list_rate_infos do
    Repo.all(RateInfo)
  end

  @doc """
  Gets a single rate_info.

  Raises `Ecto.NoResultsError` if the Rate info does not exist.

  ## Examples

      iex> get_rate_info!(123)
      %RateInfo{}

      iex> get_rate_info!(456)
      ** (Ecto.NoResultsError)

  """
  def get_rate_info!(id), do: Repo.get!(RateInfo, id)

  @doc """
  Creates a rate_info.

  ## Examples

      iex> create_rate_info(%{field: value})
      {:ok, %RateInfo{}}

      iex> create_rate_info(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_rate_info(attrs \\ %{}) do
    %RateInfo{}
    |> RateInfo.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a rate_info.

  ## Examples

      iex> update_rate_info(rate_info, %{field: new_value})
      {:ok, %RateInfo{}}

      iex> update_rate_info(rate_info, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_rate_info(%RateInfo{} = rate_info, attrs) do
    rate_info
    |> RateInfo.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a RateInfo.

  ## Examples

      iex> delete_rate_info(rate_info)
      {:ok, %RateInfo{}}

      iex> delete_rate_info(rate_info)
      {:error, %Ecto.Changeset{}}

  """
  def delete_rate_info(%RateInfo{} = rate_info) do
    Repo.delete(rate_info)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking rate_info changes.

  ## Examples

      iex> change_rate_info(rate_info)
      %Ecto.Changeset{source: %RateInfo{}}

  """
  def change_rate_info(%RateInfo{} = rate_info) do
    RateInfo.changeset(rate_info, %{})
  end
end
