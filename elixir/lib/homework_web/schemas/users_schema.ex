defmodule HomeworkWeb.Schemas.UsersSchema do
  @moduledoc """
  Defines the graphql schema for user.
  """
  use Absinthe.Schema.Notation

  alias HomeworkWeb.Resolvers.UsersResolver

  object :user do
    field(:id, non_null(:id))
    field(:dob, :string)
    field(:first_name, :string)
    field(:last_name, :string)
    @desc "primary company's id"
    field(:company_id, :id)
    field(:total_rows, :integer)
    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)

    field(:companies, list_of(:company)) do
      resolve(&UsersResolver.companies/3)
    end
  end

  object :user_mutations do
    @desc "Create a new user"
    field :create_user, :user do
      arg(:dob, non_null(:string))
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
      arg(:company_id, non_null(:id))
      arg(:primary_company, non_null(:boolean))

      resolve(&UsersResolver.create_user/3)
    end

    @desc "Update a existing user"
    field :update_user, :user do
      arg(:id, non_null(:id))
      arg(:dob, non_null(:string))
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
      arg(:company_id, non_null(:id))
      arg(:primary_company, non_null(:boolean))

      resolve(&UsersResolver.update_user/3)
    end

    @desc "Delete an existing user"
    field :delete_user, :user do
      arg(:id, non_null(:id))

      resolve(&UsersResolver.delete_user/3)
    end
  end

  object :user_queries do
    @desc "Fuzzy search for users by first name"
    field :get_users_by_first_name, list_of(:user) do
      arg(:first_name, non_null(:string))
      arg(:limit, non_null(:integer))
      arg(:offset, non_null(:integer))
      arg(:string_difference, non_null(:integer))

      resolve(&UsersResolver.fuzzy_search_users_by_first_name/3)
    end

    @desc "Fuzzy search for users by last name"
    field :get_users_by_last_name, list_of(:user) do
      arg(:last_name, non_null(:string))
      arg(:limit, non_null(:integer))
      arg(:offset, non_null(:integer))
      arg(:string_difference, non_null(:integer))

      resolve(&UsersResolver.fuzzy_search_users_by_last_name/3)
    end

    @desc "Fuzzy search for users by first and last name"
    field :get_users_by_first_and_last_name, list_of(:user) do
      arg(:first_name, non_null(:string))
      arg(:last_name, non_null(:string))
      arg(:limit, non_null(:integer))
      arg(:offset, non_null(:integer))
      arg(:string_difference, non_null(:integer))

      resolve(&UsersResolver.fuzzy_search_users_by_first_and_last_name/3)
    end
  end
end
