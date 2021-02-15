defmodule Homework.Repo.Migrations.Fuzzystrmatch do
  use Ecto.Migration

  def change do
    execute "CREATE EXTENSION IF NOT EXISTS fuzzystrmatch"
  end
end
