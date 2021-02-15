defmodule Homework.Companies do
  @moduledoc """
  The Companies context
  """

  import Ecto.Query, warn: false
  alias Homework.Repo
  alias Homework.Pagination
  alias Homework.UsdAndCentsConversions

  alias Homework.Transactions

  alias Homework.Companies.Company

  @doc """
  Returns the list of companies

  ## Examples
    
      iex> list_companies([])
      [%Company{}, ...]
    
  """
  def list_companies(args) do
    query = from c in Company
    query_with_limit_and_offset = Pagination.add_limit_and_offset(query, args.limit, args.offset)
    companies = Repo.all(query_with_limit_and_offset)
    companies = for company <- companies, do: Map.put_new(company, :total_rows, Pagination.get_total_rows(query))
    for company <- companies, do: add_available_credit_to_company(company)
  end

  @doc """
  Get a single company.

  Raises `Ecto.NoResultsError` if the Company doesn't exist.

  ## Examples

      iex> get_company!(234)
      %Company{}

      iex> get_company!(535)
      ** (Ecto.NoResultsError)

  """ 
  def get_company!(id) do
    add_available_credit_to_company(Repo.get!(Company, id))
  end

  @doc """
  Creates company's available credit from the related transactions

  ## Examples
      
      iex> add_available_credit_to_company(%Company{})
      %Company{available_credit: 10000}
  """
  def add_available_credit_to_company(company) do
    transactions = Transactions.get_transactions_by_company_id(company.id)
    company = mutate_attrs_credit_line_to_usd(company)
    credit_changes = for transaction <- transactions, do: postive_or_negative_transaction_amount(transaction)
    credit_change = List.foldl(credit_changes, 0, fn x, acc -> x + acc end)
    Map.put_new(company, :available_credit, company.credit_line + credit_change)
  end

  @doc """
  Update company's available credit from the related transactions

  ## Examples
      
      iex> update_available_credit_in_company(%Company{available_credit: 10009})
      %Company{available_credit: 10000}
  """
  def update_available_credit_in_company(company) do
    transactions = Transactions.get_transactions_by_company_id(company.id)
    company = mutate_attrs_credit_line_to_usd(company)
    credit_changes = for transaction <- transactions, do: postive_or_negative_transaction_amount(transaction)
    credit_change = List.foldl(credit_changes, 0, fn x, acc -> x + acc end)
    Map.replace(company, :available_credit, company.credit_line + credit_change)
  end

  @doc """
  Return postive or negative amount base on transactions credit or debit being true

  ## Examples
      
      iex> postive_or_negative_transaction_amount(%Transaction{credit: true, debit: false, amount: 1000, ...})
      1000

      iex> postive_or_negative_transaction_amount(%Transaction{credit: false, debit: true, amount: 1000, ...})
      -1000

      iex> postive_or_negative_transaction_amount(%Transaction{credit: true, debit: true, amount: 1000, ...})
      0

      iex> postive_or_negative_transaction_amount(%Transaction{credit: false, debit: false, amount: 1000, ...})
      0
  """
  def postive_or_negative_transaction_amount(transaction) do
    if transaction.credit == true and transaction.debit == true or transaction.credit == false and transaction.debit == false do
      0    
    else
      if transaction.credit == true and transaction.debit == false do
        transaction.amount
      else
        -transaction.amount
      end
    end
  end

  @doc """
  Creates a company.

  ## Examples

      iex> create_company(%{field: value})
      {:ok, %Company{}}

      iex> create_company(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_company(attrs \\ %{}) do
    attrs = mutate_attrs_credit_line_to_cents(attrs)
    created_company_as_list = %Company{}
    |> Company.changeset(attrs)
    |> Repo.insert()
    |> Tuple.to_list()
    if Enum.at(created_company_as_list, 0) != :error do
      company_struct = Enum.at(created_company_as_list, 1)
      company_struct = Map.put_new(company_struct, :available_credit, UsdAndCentsConversions.convert_cents_to_usd(company_struct.credit_line))
      {Enum.at(created_company_as_list, 0), mutate_attrs_credit_line_to_usd(company_struct)}
    else 
      List.to_tuple(created_company_as_list)
    end
  end

  @doc """
  Updates a company.

  ## Examples
      
      iex> update_company(company, %{field: new_value})
      {:ok, %Company{}}

      iex> update_company(company, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """ 
  def update_company(%Company{} = company, attrs) do
    attrs = mutate_attrs_credit_line_to_cents(attrs)
    updated_company_as_list = company
    |> Company.changeset(attrs)
    |> Repo.update()
    |> Tuple.to_list()
    if Enum.at(updated_company_as_list, 0) != :error do
      company_struct = Enum.at(updated_company_as_list, 1)
      {Enum.at(updated_company_as_list, 0), update_available_credit_in_company(company_struct)}
    else 
      List.to_tuple(updated_company_as_list)
    end
  end

  @doc """
  Deletes a company.

  ## Examples
      
      iex> delete_company(company)
      {:ok, %Company{}}

      iex> delete_company(company)
      {:error, %Ecto.Changeset{}}

  """
  def delete_company(%Company{} = company) do
    delete_company_as_list = Repo.delete(company)
    |> Tuple.to_list()
    if Enum.at(delete_company_as_list, 0) != :error do
      company_struct = Enum.at(delete_company_as_list, 1)
      company_struct = Map.put_new(company_struct, :available_credit, company_struct.credit_line)
      {Enum.at(delete_company_as_list, 0), company_struct}
    else 
      List.to_tuple(delete_company_as_list)
    end
  end

  @doc """
  Returns a `%Ecto.Changeset{}` for tracking company changes.

  ## Examples
      
      iex> change_company(company)
      %Ecto.Changeset{data: %Company{}}

  """
  def change_company(%Company{} = company, attrs \\ %{}) do
   Company.changeset(company, attrs)
  end

  @doc """
  Mutates struct's credit_line to usd or returns un-mutated attributes if credit_line == nil

  ## Examples

    iex> mutate_attrs_credit_line_to_usd(%{credit_line: 10000, ...})
    %{credit_line: 100.0, ...}

    iex> mutate_attrs_credit_line_to_usd(%{credit_line: nil, ...})
    %{credit_line: nil, ...}

  """
  def mutate_attrs_credit_line_to_usd(attrs) do
    if Map.has_key?(attrs, :credit_line) do
      %{attrs | credit_line: UsdAndCentsConversions.convert_cents_to_usd(attrs.credit_line)}
    else
      attrs
    end
  end
  
  @doc """
  Mutates attributes' credit_line to cents or returns un-mutated attributes if credit_line == nil

  ## Examples

    iex> mutate_attrs_credit_line_to_cents(%{credit_line: 100.0, ...})
    %{credit_line: 10000, ...}

    iex> mutate_attrs_credit_line_to_cents(%{credit_line: nil, ...})
    %{credit_line: nil, ...}

  """
  def mutate_attrs_credit_line_to_cents(attrs) do  
    if attrs.credit_line != nil do 
      %{attrs | credit_line: UsdAndCentsConversions.convert_usd_to_cents(attrs.credit_line)}
    else
      attrs
    end
  end
end