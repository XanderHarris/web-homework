defmodule HomeworkWeb.Resolvers.UsersResolver do
  alias Homework.Users
  alias Homework.UsersCompanies

  @doc """
  Get a list of users
  """
  def users(_root, args, _info) do
    {:ok, Users.list_users(args)}
  end

  @doc """
  Get a list of companies related to the user
  """
  def companies(_root, _args, %{source: %{id: id}}) do
    {:ok, UsersCompanies.get_companies_by_user_id(id)}
  end

  @doc """
  Get users that fuzzy match the first_name string in args
  """
  def fuzzy_search_users_by_first_name(_root, args, _info) do
    {:ok, Users.fuzzy_search_users_by_first_name(args)} 
  end

  @doc """
  Get users that fuzzy match the last_name string in args
  """
  def fuzzy_search_users_by_last_name(_root, args, _info) do
    {:ok, Users.fuzzy_search_users_by_last_name(args)}
  end

  @doc """
  Get users that fuzzy match the first_name and last_name strings in args
  """
  def fuzzy_search_users_by_first_and_last_name(_root, args, _info) do
    {:ok, Users.fuzzy_search_users_by_first_and_last_name(args)}
  end

  @doc """
  Creates a user
  """
  def create_user(_root, args, _info) do
    case Users.create_user(args) do
      {:ok, user} ->
        {:ok, user}

      error ->
        {:error, "could not create user: #{inspect(error)}"}
    end
  end

  @doc """
  Updates a user for an id with args specified.
  """
  def update_user(_root, %{id: id} = args, _info) do
    user = Users.get_user!(id)

    case Users.update_user(user, args) do
      {:ok, user} ->
        {:ok, user}

      error ->
        {:error, "could not update user: #{inspect(error)}"}
    end
  end

  @doc """
  Deletes a user for an id
  """
  def delete_user(_root, %{id: id}, _info) do
    user = Users.get_user!(id)

    case Users.delete_user(user) do
      {:ok, user} ->
        {:ok, user}

      error ->
        {:error, "could not update user: #{inspect(error)}"}
    end
  end
end
