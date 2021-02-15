# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Homework.Repo.insert!(%Homework.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.
import Ecto.Query, only: [from: 2]

alias Homework.Repo
alias Homework.Companies.Company
alias Homework.Merchants.Merchant
alias Homework.Transactions.Transaction
alias Homework.Users.User
alias Homework.UsersCompanies.UserCompany

company = Repo.get_by(Company, name: "Divvy")
company_result =
  if company != nil do
    transaction_query = from t in Transaction, where: t.company_id == ^company.id
    Repo.delete_all(transaction_query)
    usercompany_query = from uc in UserCompany, where: uc.company_id == ^company.id
    Repo.delete_all(usercompany_query)
    Repo.delete!(company)
    Repo.insert!(%Company{name: "Divvy", credit_line: 900000})
  else
    Repo.insert!(%Company{name: "Divvy", credit_line: 900000})
  end
user = Repo.get_by(User, first_name: "Alex")
user_result = 
  if user != nil do 
    transaction_query = from t in Transaction, where: t.user_id == ^user.id
    Repo.delete_all(transaction_query)
    usercompany_query = from uc in UserCompany, where: uc.user_id == ^user.id
    Repo.delete_all(usercompany_query)
    Repo.delete!(user)
    Repo.insert!(%User{dob: "03/11/1994", first_name: "Alex", last_name: "Connelley"})
  else 
    Repo.insert!(%User{dob: "03/11/1994", first_name: "Alex", last_name: "Connelley"})
  end
Repo.insert!(%UserCompany{user_id: user_result.id, company_id: company_result.id, primary_company: true})
merchant = Repo.get_by(Merchant, name: "Connelley")
merchant_result =
  if merchant != nil do
    query = from t in Transaction, where: t.merchant_id == ^merchant.id
    Repo.delete_all(query)
    Repo.delete!(merchant)
    Repo.insert!(%Merchant{name: "Connelley", description: "Seeding Merchants"})
  else
    Repo.insert!(%Merchant{name: "Connelley", description: "Seeding Merchants"})
  end
if merchant_result != nil and user_result != nil and company_result != nil do
  Repo.insert!(%Transaction{amount: 4000, credit: true, debit: false, description: "Seeding credit transactions", 
    user_id: user_result.id, merchant_id: merchant_result.id, company_id: company_result.id})
  Repo.insert!(%Transaction{amount: 1000, credit: false, debit: true, description: "Seeding debit transactions",
    user_id: user_result.id, merchant_id: merchant_result.id, company_id: company_result.id})
end