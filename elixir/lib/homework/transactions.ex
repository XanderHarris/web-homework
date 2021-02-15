defmodule Homework.Transactions do
  @moduledoc """
  The Transactions context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo
  alias Homework.Pagination
  alias Homework.UsdAndCentsConversions

  alias Homework.UsersCompanies

  alias Homework.Transactions.Transaction

  @doc """
  Returns the list of transactions.

  ## Examples

      iex> list_transactions([])
      [%Transaction{}, ...]

  """
  def list_transactions(args) do
    query = from t in Transaction
    query_with_limit_and_offset = Pagination.add_limit_and_offset(query, args.limit, args.offset)
    transactions = Repo.all(query_with_limit_and_offset)
    transactions = for transaction <- transactions, do: Map.put_new(transaction, :total_rows, Pagination.get_total_rows(query))
    for transaction <- transactions, do: mutate_attrs_amount_to_usd(transaction)
  end

  @doc """
  Gets transactions where amount is between min and max

  ## Examples

      iex> get_transactions_where_amount_between_min_and_max(%{min: 0.0, max 100000.0})
      [%Transaction{amount: 1000, ...}, ...]

  """
  def get_transactions_where_amount_between_min_and_max(args) do
    min = UsdAndCentsConversions.convert_usd_to_cents(args.min)
    max = UsdAndCentsConversions.convert_usd_to_cents(args.max)
    query = from t in Transaction, where: t.amount >= ^min and t.amount <= ^max # This is a between because query because ecto doesn't have a between function
    query_with_limit_and_offset = Pagination.add_limit_and_offset(query, args.limit, args.offset)
    transactions = Repo.all(query_with_limit_and_offset)
    transactions = for transaction <- transactions, do: Map.put_new(transaction, :total_rows, Pagination.get_total_rows(query))
    for transaction <- transactions, do: mutate_attrs_amount_to_usd(transaction)
  end

  @doc """
  Gets transactions by company id

  ## Examples

      iex> get_transactions_by_company_id(5395)
      [%Transaction{}, ...]

  """
  def get_transactions_by_company_id(company_id) do
    query = from t in Transaction, where: t.company_id == ^company_id
    for transaction <- Repo.all(query), do: mutate_attrs_amount_to_usd(transaction)
  end

  @doc """
  Gets a single transaction.

  Raises `Ecto.NoResultsError` if the Transaction does not exist.

  ## Examples

      iex> get_transaction!(123)
      %Transaction{}

      iex> get_transaction!(456)
      ** (Ecto.NoResultsError)

  """
  def get_transaction!(id), do: mutate_attrs_amount_to_usd(Repo.get!(Transaction, id))

  @doc """
  Creates a transaction.

  ## Examples

      iex> create_transaction(%{field: value})
      {:ok, %Transaction{}}

      iex> create_transaction(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_transaction(attrs \\ %{}) do
    attrs = mutate_attrs_amount_to_cents(attrs)
    if attrs.user_id != nil and attrs.company_id != nil do
      if UsersCompanies.get_userscompanies_by_user_id_and_company_id(attrs.user_id, attrs.company_id) != nil do
        created_transaction_as_list = %Transaction{}
        |> Transaction.changeset(attrs)
        |> Repo.insert()
        |> Tuple.to_list()
        created_usd_transaction = mutate_attrs_amount_to_usd(Enum.at(created_transaction_as_list, 1))
        {Enum.at(created_transaction_as_list, 0), created_usd_transaction}
      else
        {:error, "User and Company aren't related"}
      end
    else
      created_transaction_as_list = %Transaction{}
        |> Transaction.changeset(attrs)
        |> Repo.insert()
        |> Tuple.to_list()
        created_usd_transaction = mutate_attrs_amount_to_usd(Enum.at(created_transaction_as_list, 1))
        {Enum.at(created_transaction_as_list, 0), created_usd_transaction}
    end
  end

  @doc """
  Updates a transaction.

  ## Examples

      iex> update_transaction(transaction, %{field: new_value})
      {:ok, %Transaction{}}

      iex> update_transaction(transaction, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_transaction(%Transaction{} = transaction, attrs) do
    attrs = mutate_attrs_amount_to_cents(attrs)
    if attrs.user_id != nil and attrs.company_id != nil do
      if UsersCompanies.get_userscompanies_by_user_id_and_company_id(attrs.user_id, attrs.company_id) != nil do
        updated_transaction_as_list = transaction
        |> Transaction.changeset(attrs)
        |> Repo.update()
        |> Tuple.to_list()
        updated_usd_transaction = mutate_attrs_amount_to_usd(Enum.at(updated_transaction_as_list, 1))
        {Enum.at(updated_transaction_as_list, 0), updated_usd_transaction}
      else
        {:error, "User and Company aren't related"}
      end
    else
      transaction
        |> Transaction.changeset(attrs)
        |> Repo.update()
    end
  end

  @doc """
  Deletes a transaction.

  ## Examples

      iex> delete_transaction(transaction)
      {:ok, %Transaction{}}

      iex> delete_transaction(transaction)
      {:error, %Ecto.Changeset{}}

  """
  def delete_transaction(%Transaction{} = transaction) do
    Repo.delete(transaction)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking transaction changes.

  ## Examples

      iex> change_transaction(transaction)
      %Ecto.Changeset{data: %Transaction{}}

  """
  def change_transaction(%Transaction{} = transaction, attrs \\ %{}) do
    Transaction.changeset(transaction, attrs)
  end

  @doc """
  Mutates struct's amount to usd or returns un-mutated attributes if amount == nil

  ## Examples

    iex> mutate_attrs_amount_to_usd(%{amount: 10000, ...})
    %{amount: 100.0, ...}

    iex> mutate_attrs_amount_to_usd(%{amount: nil, ...})
    %{amount: nil, ...}

  """
  def mutate_attrs_amount_to_usd(attrs) do
    if Map.has_key?(attrs, :amount) do
      %{attrs | amount: UsdAndCentsConversions.convert_cents_to_usd(attrs.amount)}
    else
      attrs
    end
  end
  
  @doc """
  Mutates attributes' amount to cents or returns un-mutated attributes if amount == nil

  ## Examples

    iex> mutate_attrs_amount_to_cents(%{amount: 100.0, ...})
    %{amount: 10000, ...}

    iex> mutate_attrs_amount_to_cents(%{amount: nil, ...})
    %{amount: nil, ...}

  """
  def mutate_attrs_amount_to_cents(attrs) do  
    if attrs.amount != nil do 
      %{attrs | amount: UsdAndCentsConversions.convert_usd_to_cents(attrs.amount)}
    else
      attrs
    end
  end
end
