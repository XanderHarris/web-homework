defmodule Homework.Repo.Migrations.CreateUsersCompanies do
  use Ecto.Migration

  def change do
    create table(:users_companies, primary_key: false) do
      add(:id, :uuid, primary_key: true)
      add(:user_id, references(:users, type: :uuid, on_delete: :nothing))
      add(:company_id, references(:companies, type: :uuid, on_delete: :nothing))
      add(:primary_company, :boolean)

      timestamps()
    end
  end
end