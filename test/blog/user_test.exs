defmodule Blog.UserTest do
  use Blog.DataCase

  alias Blog.Users

  describe "users" do
    alias Blog.Model.User
    import Blog.UserFixture


    test "list of all users" do
      IO.inspect("Running test -- list of all users -- ...")
      user = user_fixtures()
      assert [user] == Users.get_all_users()
    end


    test "get_user/1 returns user with given id" do
      IO.inspect("Running test -- get_user/1 returns user with given id -- ...")
      user = user_fixtures()
      assert Blog.Users.get_user_by_id(user.id) == user
    end

    test "create_user/1 with valid data creates a user" do
      IO.inspect("Running test -- create_user/1 with valid data creates a user -- ...")
      valid_data = %{
        "fname" => "fname",
        "lname" => "lname",
        "email" => "email@email",
        "password" => "password"
      }
      assert {:ok, %User{} = user} = Users.create_user(valid_data)
      assert user.fname == valid_data["fname"]
      assert user.lname == valid_data["lname"]
      assert user.email == valid_data["email"]
      assert user.password == valid_data["password"]
    end

    test "create_user/1 with invalid data return error changeset" do
      IO.inspect("Running test -- create_user/1 with invalid data return error changeset -- ...")
      invalid_data = %{
        "fname" => nil,
        "lname" => nil,
        "email" => "email@email",
        "password" => nil
      }
      assert {:error, %Ecto.Changeset{}} = Users.create_user(invalid_data)
    end

    test "update_user/2 with valid data updates user" do
      IO.inspect("Running test -- update_user/2 with valid data updates user -- ...")
      user = user_fixtures()
      valid_data = %{fname: "some updated fname",
      lname: "some updated lname",
      email: "some updated email",
      password: "some updated password"}
      assert {:ok, %User{} = updated_user} = Users.updated_user(user, valid_data)
      assert updated_user.fname == valid_data.fname
      assert updated_user.lname == valid_data.lname
      assert updated_user.email == valid_data.email
      assert updated_user.password == valid_data.password
    end

    test "update_user/2 with invalid data return error changeset" do
      IO.inspect("Running test -- update_user/2 with invalid data return error changeset -- ...")
      invalid_data = %{"fname" => nil,
      "lname" => nil,
      "email" => nil,
      "password" => nil}
      user = user_fixtures()
      assert {:error, %Ecto.Changeset{}} = Users.updated_user(user, invalid_data)
      assert user == Users.get_user_by_id(user.id)
    end

    test "delete_user/1 deletes user" do
      IO.inspect("Running test -- delete_user/1 deletes user -- ...")
      user = user_fixtures()
      assert {:ok, %User{}} = Users.delete_user(user)
      assert nil == Users.get_user_by_id(user.id)
    end
  end
end
