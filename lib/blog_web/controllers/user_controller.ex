defmodule BlogWeb.UserController do
  use BlogWeb, :controller
  alias Blog.Users
  alias Phoenix.Token

  action_fallback BlogWeb.FallbackController


  def create(conn, %{"user" => user_details}) do
    if password_field_empty?(user_details["password"]) do
      render(conn, :error_handler, error: "password can't be blank")
    else
      encrpted_password = Argon2.hash_pwd_salt(user_details["password"])
      user_details = Map.put user_details, "password", encrpted_password
      with {:ok, newUser} <- Users.create_user(user_details) do
        IO.inspect(newUser)
        render(conn, :user_response, user: newUser, msg: "User created")
      end
    end
  end

  def login(conn, %{"user" => %{"email" => useremail, "password" => plain_password} }) do
    with %Blog.Model.User{} = user <- Users.get_user_by_email(useremail),
    true <- Argon2.verify_pass(plain_password, user.password)
     do
      token = Token.sign(BlogWeb.Endpoint, "somekey", user.id)
      render(conn, :user_response, token: token, user: user, msg: "Token created")
    end
  end

  def edit(conn, %{"user" => user_details}) do
    current_user = conn.assigns.user
    if user_details["password"] != nil and !password_field_empty?(user_details["password"]) do
      encrypted_password = Argon2.hash_pwd_salt(user_details["password"])
      user_details = Map.put user_details, "password", encrypted_password
      with {:ok, updated_user} <- Users.updated_user(current_user, user_details) do
        render(conn, :user_response, user: updated_user, msg: "Edited")
      end
    else
      with {:ok, updated_user} <- Users.updated_user(current_user, user_details) do
        render(conn, :user_response, user: updated_user, msg: "Edited")
      end
    end
  end

  def delete(conn, _params) do
    user = conn.assigns.user
    with {:ok, deleted_user} <- Users.delete_user(user)
    do
      render(conn, :user_response, user: deleted_user, msg: "Deleted")
    end
  end

  defp password_field_empty?(pass) do
    if pass === "" do
      true
    else
      false
    end
  end

end
