defmodule Homework.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query, warn: false
  alias Homework.Repo
  alias Homework.Pagination

  alias Homework.UsersCompanies

  alias Homework.Users.User

  @doc """
  Returns the list of users.

  ## Examples

      iex> list_users([])
      [%User{}, ...]

  """
  def list_users(args) do
    query = from u in User
    query_with_limit_and_offset = Pagination.add_limit_and_offset(query, args.limit, args.offset)
    users = Repo.all(query_with_limit_and_offset)
    users = for user <- users, do: Map.put_new(user, :total_rows, Pagination.get_total_rows(query))
    for user <- users, do: set_user_primary_company_id(user, user.id)
  end

  @doc """
  Gets all users that have a first name that fuzzy matches the given first name by 5 or less string distance

  ## Examples

      iex> fuzzy_search_users_by_first_name(%{first_name: "Alec"})
      [%User{first_name: "Alec", ...}, %User{first_name: "Alex", ...},...]

  """
  def fuzzy_search_users_by_first_name(args) do
    query = from u in User, where: fragment("levenshtein(?, ?)", u.first_name, ^args.first_name) <= ^args.string_difference
    query_with_limit_and_offset = Pagination.add_limit_and_offset(query, args.limit, args.offset)
    users = Repo.all(query_with_limit_and_offset)
    users = for user <- users, do: Map.put_new(user, :total_rows, Pagination.get_total_rows(query))
    for user <- users, do: set_user_primary_company_id(user, user.id)
  end

  @doc """
  Gets all users that have a last name that fuzzy matches the given last name by 5 or less string distance

  ## Examples

      iex> fuzzy_search_users_by_last_name(%{last_name: "Connelly"})
      [%User{last_name: "Connelly", ...}, %User{last_name: "Connelley"}, ...]

  """
  def fuzzy_search_users_by_last_name(args) do
    query = from u in User, where: fragment("levenshtein(?, ?)", u.last_name, ^args.last_name) <= ^args.string_difference
    query_with_limit_and_offset = Pagination.add_limit_and_offset(query, args.limit, args.offset)
    users = Repo.all(query_with_limit_and_offset)
    users = for user <- users, do: Map.put_new(user, :total_rows, Pagination.get_total_rows(query))
    for user <- users, do: set_user_primary_company_id(user, user.id)
  end

  @doc """
  Gets all users that have a first and last name that fuzzy matches the given first and last name by 5 or less string distance each

  ## Examples
    
      iex> fuzzy_search_users_by_first_and_last_name(%{firts_name: "Alec", last_name: "Connelley"})
      [%User{first_name: "Alec", last_name: "Connelly", ...}, %User{first_name: "Alex", last_name: "Connelley", ...}]

  """
  def fuzzy_search_users_by_first_and_last_name(args) do
    query = from u in User, where: fragment("levenshtein(?, ?)", u.first_name, ^args.first_name) <= ^args.string_difference and 
      fragment("levenshtein(?, ?)", u.last_name, ^args.last_name) <= ^args.string_difference
    query_with_limit_and_offset = Pagination.add_limit_and_offset(query, args.limit, args.offset)
    users = Repo.all(query_with_limit_and_offset)
    users = for user <- users, do: Map.put_new(user, :total_rows, Pagination.get_total_rows(query))
    for user <- users, do: set_user_primary_company_id(user, user.id)
  end

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id) do 
    user = Repo.get!(User, id)
    set_user_primary_company_id(user, id)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    created_user_as_list = %User{}
    |> User.changeset(attrs)
    |> Repo.insert()
    |> Tuple.to_list()
    if Enum.at(created_user_as_list, 0) != :error do
      created_user_struct = Enum.at(created_user_as_list, 1)
      UsersCompanies.create_usercompany(%{user_id: created_user_struct.id, company_id: attrs.company_id, primary_company: attrs.primary_company})
      created_user_struct = if attrs.primary_company == true do
        Map.put_new(created_user_struct, :company_id, attrs.company_id)
      else
        created_user_struct
      end
      List.to_tuple(List.replace_at(created_user_as_list, 1, created_user_struct))
    else
      List.to_tuple(created_user_as_list)
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    updated_user_as_list = user
    |> User.changeset(attrs)
    |> Repo.update()
    |> Tuple.to_list()
    if Enum.at(updated_user_as_list, 0) != :error do
      updated_user_struct = Enum.at(updated_user_as_list, 1)
      usercompany = UsersCompanies.get_userscompanies_by_user_id_and_company_id(updated_user_struct.id, attrs.company_id)
      if usercompany == nil do
        if attrs.primary_company == true do
          update_old_userscompanies(updated_user_struct)
          UsersCompanies.create_usercompany(%{user_id: updated_user_struct.id, company_id: attrs.company_id, primary_company: attrs.primary_company})
          update_company_id_and_back_to_tuple(updated_user_struct, updated_user_as_list, attrs.company_id)
        else
          UsersCompanies.create_usercompany(%{user_id: updated_user_struct.id, company_id: attrs.company_id, primary_company: attrs.primary_company})
          set_updated_user_primary_company_id(updated_user_struct, updated_user_as_list)
        end
      else 
        if attrs.primary_company == true do
          if usercompany.primary_company == false do
            update_old_userscompanies(updated_user_struct)
            UsersCompanies.update_usercompany(usercompany, %{user_id: updated_user_struct.id, company_id: attrs.company_id, primary_company: attrs.primary_company})
            update_company_id_and_back_to_tuple(updated_user_struct, updated_user_as_list, attrs.company_id)
          else
            update_company_id_and_back_to_tuple(updated_user_struct, updated_user_as_list, attrs.company_id)
          end
        else
          if usercompany.primary_company == true do
            UsersCompanies.update_usercompany(usercompany, %{user_id: updated_user_struct.id, company_id: attrs.company_id, primary_company: attrs.primary_company})
            update_company_id_and_back_to_tuple(updated_user_struct, updated_user_as_list, nil)
          else
            set_updated_user_primary_company_id(updated_user_struct, updated_user_as_list)
          end
        end
      end
    else
      List.to_tuple(updated_user_as_list)
    end
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    user = set_user_primary_company_id(user, user.id)
    for usercompany <- UsersCompanies.get_userscompanies_by_user_id(user.id), do: Repo.delete(usercompany)
    Repo.delete(user)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking user changes.

  ## Examples

      iex> change_user(user)
      %Ecto.Changeset{data: %User{}}

  """
  def change_user(%User{} = user, attrs \\ %{}) do
    User.changeset(user, attrs)
  end

  @doc """
  Set user's primary company id

  ## Examples

      iex> set_user_primary_company_id(35545)
      %User{company_id: 4564646, ...}

  """
  def set_user_primary_company_id(user, user_id) do
    usercompany = UsersCompanies.get_primary_company_for_user_id(user_id)
    if usercompany != nil do
      Map.put_new(user, :company_id, usercompany.company_id)
    else
      Map.put_new(user, :company_id, nil)
    end
  end

  @doc """
  Set user's primary company id and call update company id and back to tuple

  ## Examples

      iex> set_user_primary_company_id(35545)
      %User{company_id: 4564646, ...}

  """
  def set_updated_user_primary_company_id(updated_user_struct, updated_user_as_list) do
    usercompany = UsersCompanies.get_primary_company_for_user_id(updated_user_struct.id)
    if usercompany != nil do
      update_company_id_and_back_to_tuple(updated_user_struct, updated_user_as_list, usercompany.company_id)
    else
      update_company_id_and_back_to_tuple(updated_user_struct, updated_user_as_list, nil)
    end
  end

  @doc """
  Update old userscompanies so that they are no longer the primary company
  """
  def update_old_userscompanies(updated_user_struct) do
    userscompanies = UsersCompanies.get_userscompanies_by_user_id(updated_user_struct.id)
    for updated_usercompany <- userscompanies, do: UsersCompanies.update_usercompany(updated_usercompany, Map.new(user_id: updated_usercompany.user_id, 
      company_id: updated_usercompany.company_id, primary_company: false))
  end

  @doc """
  Update user's company id and turn the list back in to a tuple
  """
  def update_company_id_and_back_to_tuple(updated_user_struct, updated_user_as_list, company_id) do
    updated_user_struct = Map.replace(updated_user_struct, :company_id, company_id)
    List.to_tuple(List.replace_at(updated_user_as_list, 1, updated_user_struct))
  end
end
