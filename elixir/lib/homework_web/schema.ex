defmodule HomeworkWeb.Schema do
  @moduledoc """
  Defines the graphql schema for this project.
  """
  use Absinthe.Schema

  alias HomeworkWeb.Resolvers.CompaniesResolver
  alias HomeworkWeb.Resolvers.MerchantsResolver
  alias HomeworkWeb.Resolvers.TransactionsResolver
  alias HomeworkWeb.Resolvers.UsersResolver
  import_types(HomeworkWeb.Schemas.Types)

  query do
    @desc "Get all Transactions"
    field(:transactions, list_of(:transaction)) do
      arg(:limit, non_null(:integer))
      arg(:offset, non_null(:integer))

      resolve(&TransactionsResolver.transactions/3)
    end

    import_fields(:transaction_queries)

    @desc "Get all Users"
    field(:users, list_of(:user)) do
      arg(:limit, non_null(:integer))
      arg(:offset, non_null(:integer))
      
      resolve(&UsersResolver.users/3)
    end

    import_fields(:user_queries)

    @desc "Get all Merchants"
    field(:merchants, list_of(:merchant)) do
      arg(:limit, non_null(:integer))
      arg(:offset, non_null(:integer))

      resolve(&MerchantsResolver.merchants/3)
    end

    import_fields(:merchant_queries)

    @desc "Get all Companies"
    field(:companies, list_of(:company)) do
      arg(:limit, non_null(:integer))
      arg(:offset, non_null(:integer))
      
      resolve(&CompaniesResolver.companies/3)
    end
  end

  mutation do
    import_fields(:transaction_mutations)
    import_fields(:user_mutations)
    import_fields(:merchant_mutations)
    import_fields(:company_mutations)
  end
end
