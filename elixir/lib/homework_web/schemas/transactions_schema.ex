defmodule HomeworkWeb.Schemas.TransactionsSchema do
  @moduledoc """
  Defines the graphql schema for transactions.
  """
  use Absinthe.Schema.Notation

  alias HomeworkWeb.Resolvers.TransactionsResolver

  object :transaction do
    field(:id, non_null(:id))
    field(:user_id, :id)
    field(:amount, :float)
    field(:credit, :boolean)
    field(:debit, :boolean)
    field(:description, :string)
    field(:merchant_id, :id)
    field(:company_id, :id)
    field(:total_rows, :id)
    field(:inserted_at, :naive_datetime)
    field(:updated_at, :naive_datetime)

    field(:user, :user) do
      resolve(&TransactionsResolver.user/3)
    end

    field(:merchant, :merchant) do
      resolve(&TransactionsResolver.merchant/3)
    end

    field(:company, :company) do
      resolve(&TransactionsResolver.company/3)
    end
  end

  object :transaction_mutations do
    @desc "Create a new transaction"
    field :create_transaction, :transaction do
      arg(:user_id, non_null(:id))
      arg(:merchant_id, non_null(:id))
      arg(:company_id, non_null(:id))
      @desc "amount is in USD format ie. 20.99"
      arg(:amount, non_null(:float))
      arg(:credit, non_null(:boolean))
      arg(:debit, non_null(:boolean))
      arg(:description, non_null(:string))

      resolve(&TransactionsResolver.create_transaction/3)
    end

    @desc "Update a new transaction"
    field :update_transaction, :transaction do
      arg(:id, non_null(:id))
      arg(:user_id, non_null(:id))
      arg(:merchant_id, non_null(:id))
      arg(:company_id, non_null(:id))
      @desc "amount is in USD format ie. 20.99"
      arg(:amount, non_null(:float))
      arg(:credit, non_null(:boolean))
      arg(:debit, non_null(:boolean))
      arg(:description, non_null(:string))

      resolve(&TransactionsResolver.update_transaction/3)
    end

    @desc "delete an existing transaction"
    field :delete_transaction, :transaction do
      arg(:id, non_null(:id))

      resolve(&TransactionsResolver.delete_transaction/3)
    end
  end

  object :transaction_queries do
    @desc "Get transactions where amount between min and mix"
    field :get_transactions_where_amount_between_min_and_max, list_of(:transaction) do
      arg(:min, non_null(:float))
      arg(:max, non_null(:float))
      arg(:limit, non_null(:integer))
      arg(:offset, non_null(:integer))

      resolve(&TransactionsResolver.get_transactions_where_amount_between_min_and_max/3)
    end
  end
end
