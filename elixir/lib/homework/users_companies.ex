defmodule Homework.UsersCompanies do
  @moduledoc """
  The UsersCompanies context
  """

  import Ecto.Query, warn: false
  alias Homework.Repo

  alias Homework.Companies

  alias Homework.UsersCompanies.UserCompany

  @doc """
  Gets a single users companies joint object.

  Raises `Ecto.NoResultsError` if the UserCompany does not exist.

  ## Examples

      iex> get_usercompany!(123)
      %UserCompany{}

      iex> get_usercompany!(456)
      ** (Ecto.NoResultsError)

  """
  def get_usercompany!(id), do: Repo.get!(UserCompany, id)

  @doc """
  Get the primary company for the given user_id

  ## Examples

      iex> get_primary_company_for_user_id(38583)
      %UserCompany{}

  """
  def get_primary_company_for_user_id(user_id) do
    Repo.get_by(UserCompany, [user_id: user_id, primary_company: true])
  end

  @doc """
  Get users companies joint object by user id

  ## Examples
      
      iex> get_userscompanies_by_user_id(1332)
      [%UserCompany{}, ...]

  """
  def get_userscompanies_by_user_id(user_id) do
    query = from uc in UserCompany, where: uc.user_id == ^user_id
    Repo.all(query)
  end

  @doc """
  Get users companies joint object by user id

  ## Examples
      
      iex> get_userscompanies_by_user_id(1332)
      [%UserCompany{}, ...]

  """
  def get_companies_by_user_id(user_id) do
    query = from uc in UserCompany, where: uc.user_id == ^user_id
    userscompanies = Repo.all(query)
    for usercompany <- userscompanies, do: Companies.get_company!(usercompany.company_id)
  end

  @doc """
  Get users companies joint object by company id

  ## Examples
      
      iex> get_userscompanies_by_company_id(5435)
      [%UserCompany{}, ...]

  """
  def get_userscompanies_by_company_id(company_id) do
    query = from uc in UserCompany, where: uc.company_id == ^company_id
    Repo.all(query)
  end
  
  @doc """
  Get users companies joint object by company id

  ## Examples
      
      iex> get_userscompanies_by_user_id_and_company_id(45436, 5435)
      [%UserCompany{}, ...]

  """
  def get_userscompanies_by_user_id_and_company_id(user_id, company_id) do
    Repo.get_by(UserCompany, [company_id: company_id, user_id: user_id])
  end

  @doc """
  Create a new user company joint object

  ## Examples
    
      iex> create_usercompany(%{field: value})
      {:ok, %UserCompany{}}

      iex> create_usercompany(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_usercompany(attrs) do
    %UserCompany{}
    |> UserCompany.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a user company joint object only used by user_update which already finds the old object

  ## Examples
      
      iex> update_usercompany(usercompany, %{field: value})
      {:ok, %UserCompany{}}

      iex> update_usercompany(usercompany, %{field: bad_value})
      {:error, %Ecto.Changeset{}}
  """
  def update_usercompany(%UserCompany{} = usercompany, attrs) do
    usercompany
    |> UserCompany.changeset(attrs)
    |> Repo.update()
  end
end