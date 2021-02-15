defmodule Homework.UsersCompanies.UserCompany do
  use Ecto.Schema
  import Ecto.Changeset
  alias Homework.Users.User
  alias Homework.Companies.Company

  @primary_key {:id, :binary_id, autogenerate: true}
  schema "users_companies" do
    belongs_to(:user, User, type: :binary_id, foreign_key: :user_id)
    belongs_to(:company, Company, type: :binary_id, foreign_key: :company_id)

    field(:primary_company, :boolean, default: false)

    timestamps()
  end

  @doc false
  def changeset(user_company, attrs) do
    user_company
    |> cast(attrs, [:user_id, :company_id, :primary_company])
    |> validate_required([:user_id, :company_id, :primary_company])
  end
end