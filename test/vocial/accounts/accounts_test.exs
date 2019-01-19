defmodule Vocial.AccountTest do 
  use Vocial.DataCase 

  alias Vocial.Accounts 

  describe "user" do
    @valid_attrs %{username: "test", email: "test@test.com", active: true,  password: "test", password_confirmation: "test"}

    def user_fixture(attrs \\ %{}) do 
      with create_attrs <- Map.merge(@valid_attrs, attrs),
           {:ok, user} <- Accounts.create_user(create_attrs)
      do 
        user |> Map.merge(%{password: nil, password_confirmation: nil})
      end
    end

    test "list_user/0 returns all user" do 
      user = user_fixture()
      assert Accounts.list_users() == [user]
    end

    test "get_usre/1 return the use with the id" do 
      user = user_fixture()
      assert Accounts.get_user(user.id) == user
    end

    test "new_user/0 return a blank changeset" do 
      changeset = Accounts.new_user()
      assert changeset.__struct__ == Ecto.Changeset
    end

    test "create_user/1 create the user in the db and return it" do 
      before = Accounts.list_users()
      user = user_fixture()
      updated = Accounts.list_users()
      assert !Enum.any?(before, fn u -> user == u end)
      assert Enum.any?(updated, fn u -> user == u end)
    end 

    test "create_user/1 fail to create the user without a password and password_confirmation" do 
      {:error, changeset} = user_fixture(%{password: nil, password_confirmation: nil})
      assert !changeset.valid?
    end

    test "create_user/1 faild to create the user when the password and the password_confirmation don't match" do 
      {:error, changeset} = user_fixture(%{password: "test", password_confirmation: "fail"})
      assert !changeset.valid?
    end

  end

end