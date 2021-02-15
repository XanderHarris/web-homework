defmodule Homework.UsersTest do
  use Homework.DataCase

  alias Homework.Users
  alias Homework.Companies

  describe "users" do
    alias Homework.Users.User

    setup do
      {:ok, company1} =
        Companies.create_company(%{
          name: "some name",
          credit_line: 0.42
        })

      {:ok, company2} =
        Companies.create_company(%{
          name: "some updated name",
          credit_line: 0.43
        })  

      valid_attrs = %{
        dob: "some dob", 
        first_name: "some first_name", 
        last_name: "some last_name", 
        company_id: company1.id,
        primary_company: true
      }
      
      update_attrs = %{
        dob: "some updated dob",
        first_name: "some updated first_name",
        last_name: "some updated last_name",
        company_id: company2.id,
        primary_company: false
      }

      invalid_attrs = %{
        dob: nil, 
        first_name: nil, 
        last_name: nil, 
        company_id: nil, 
        primary_company: nil
      }

      {:ok,
       %{
         valid_attrs: valid_attrs,
         update_attrs: update_attrs,
         invalid_attrs: invalid_attrs,
         company1: company1,
         company2: company2
       }}
    end

    def user_fixture(valid_attrs, attrs \\ %{}) do
      {:ok, user} =
        attrs
        |> Enum.into(valid_attrs)
        |> Users.create_user()

      user
    end

    test "list_users/1 returns all users", %{valid_attrs: valid_attrs} do
      user = user_fixture(valid_attrs)
      user = Map.put_new(user, :total_rows, 1)
      assert Users.list_users(%{limit: 1, offset: 0}) == [user]
    end

    test "fuzzy_search_users_by_first_name/1 returns users with close enough first names", %{valid_attrs: valid_attrs} do
      user = user_fixture(valid_attrs)
      user = Map.put_new(user, :total_rows, 1)
      assert Enum.member?(Users.fuzzy_search_users_by_first_name(%{first_name: "some first", string_difference: 5, limit: 1, offset: 0}), user) == true
      assert Enum.member?(Users.fuzzy_search_users_by_first_name(%{first_name: "sien first_nema", string_difference: 5, limit: 1, offset: 0}), user) == true
      assert Enum.member?(Users.fuzzy_search_users_by_first_name(%{first_name: "car town race", string_difference: 5, limit: 1, offset: 0}), user) == false
    end

    test "fuzzy_search_users_by_last_name/1 returns users with close enough last names", %{valid_attrs: valid_attrs} do
      user = user_fixture(valid_attrs)
      user = Map.put_new(user, :total_rows, 1)
      assert Enum.member?(Users.fuzzy_search_users_by_last_name(%{last_name: "some last", string_difference: 5, limit: 1, offset: 0}), user) == true
      assert Enum.member?(Users.fuzzy_search_users_by_last_name(%{last_name: "sien last_nema", string_difference: 5, limit: 1, offset: 0}), user) == true
      assert Enum.member?(Users.fuzzy_search_users_by_last_name(%{last_name: "plane village fly", string_difference: 5, limit: 1, offset: 0}), user) == false
    end
    
    test "fuzzy_search_users_by_first_and_last_name/1 returns users with close enough first and last names", %{valid_attrs: valid_attrs} do
      user = user_fixture(valid_attrs)
      user = Map.put_new(user, :total_rows, 1)
      assert Enum.member?(Users.fuzzy_search_users_by_first_and_last_name(%{first_name: "some first", last_name: "some last", string_difference: 5, limit: 1, offset: 0}), user) == true
      assert Enum.member?(Users.fuzzy_search_users_by_first_and_last_name(%{first_name: "sien first_nema", last_name: "sien last_nema", 
        string_difference: 5, limit: 1, offset: 0}), user) == true
      assert Enum.member?(Users.fuzzy_search_users_by_first_and_last_name(%{first_name: "car town race", last_name: "plane village fly", 
        string_difference: 5, limit: 1, offset: 0}), user) == false
      assert Enum.member?(Users.fuzzy_search_users_by_first_and_last_name(%{first_name: "some first", last_name: "plane village fly", 
        string_difference: 5, limit: 1, offset: 0}), user) == false
      assert Enum.member?(Users.fuzzy_search_users_by_first_and_last_name(%{first_name: "car town race", last_name: "some last", 
        string_difference: 5, limit: 1, offset: 0}), user) == false
    end

    test "get_user!/1 returns the user with given id", %{valid_attrs: valid_attrs} do
      user = user_fixture(valid_attrs)
      assert Users.get_user!(user.id) == user
    end

    test "create_user/1 with valid data creates a user", %{valid_attrs: valid_attrs, company1: company1} do
      assert {:ok, %User{} = user} = Users.create_user(valid_attrs)
      assert user.dob == "some dob"
      assert user.first_name == "some first_name"
      assert user.last_name == "some last_name"
      assert user.company_id == company1.id
    end

    test "create_user/1 with invalid data returns error changeset", %{invalid_attrs: invalid_attrs} do
      assert {:error, %Ecto.Changeset{}} = Users.create_user(invalid_attrs)
    end

    test "update_user/2 with valid data updates the user", %{valid_attrs: valid_attrs, update_attrs: update_attrs} do
      user = user_fixture(valid_attrs)
      assert {:ok, %User{} = user} = Users.update_user(user, update_attrs)
      assert user.dob == "some updated dob"
      assert user.first_name == "some updated first_name"
      assert user.last_name == "some updated last_name"
    end

    test "update_user/2 with invalid data returns error changeset", %{valid_attrs: valid_attrs, invalid_attrs: invalid_attrs} do
      user = user_fixture(valid_attrs)
      assert {:error, %Ecto.Changeset{}} = Users.update_user(user, invalid_attrs)
      assert user == Users.get_user!(user.id)
    end

    test "delete_user/1 deletes the user", %{valid_attrs: valid_attrs} do
      user = user_fixture(valid_attrs)
      assert {:ok, %User{}} = Users.delete_user(user)
      assert_raise Ecto.NoResultsError, fn -> Users.get_user!(user.id) end
    end

    test "change_user/1 returns a user changeset", %{valid_attrs: valid_attrs} do
      user = user_fixture(valid_attrs)
      assert %Ecto.Changeset{} = Users.change_user(user)
    end
  end
end
