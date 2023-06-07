defmodule BlogWeb.UserController do
  use BlogWeb, :controller
  alias Blog.Users
  import BlogWeb.FormatError
  alias Phoenix.Token


  def create(conn, %{"user" => user_details}) do
    if password_field_empty?(user_details["password"]) do
      render(conn, :error_handler, error: "password can't be blank")
    else
      encrpted_password = Argon2.hash_pwd_salt(user_details["password"])
      user_details = Map.put user_details, "password", encrpted_password
      case Users.create_user(user_details) do
        {:ok, newUser} -> render(conn, :user_response, user: newUser, msg: "User created")
        {:error, changeset} ->
          render(conn, :error_handler, error: format_error_changeset(changeset))
      end
    end
  end

  def login(conn, %{"user" => %{"email" => useremail, "password" => plain_password} }) do
    case Users.get_user_by_email(useremail) do
      nil -> render(conn, :error_handler, error: "invalid email or password")
      user ->
        case Argon2.verify_pass(plain_password, user.password) do
          true ->
            token = Token.sign(BlogWeb.Endpoint, "somekey", user.id)
            render(conn, :user_response, token: token, user: user, msg: "Token created")
          _ -> render(conn, :error_handler, error: "invalid email or password")
        end
    end
  end

  def edit(conn, %{"user" => user_details}) do
    current_user = conn.assigns.user
    if user_details["password"] != nil do
      encrypted_password = Argon2.hash_pwd_salt(user_details["password"])
      user_details = Map.put user_details, "password", encrypted_password
      case Users.updated_user(current_user, user_details) do
        {:ok, updated_user} -> render(conn, :user_response, user: updated_user, msg: "Edited")
        {:error, changeset} -> render(conn, :error_handler, error: format_error_changeset(changeset))
      end
    else
      case Users.updated_user(current_user, user_details) do
        {:ok, updated_user} -> render(conn, :user_response, user: updated_user, msg: "Edited")
        {:error, changeset} -> render(conn, :error_handler, error: format_error_changeset(changeset))
      end
    end
  end

  def delete(conn, _params) do
    user = conn.assigns.user
    case Users.delete_user(user) do
      {:ok, deleted_user} -> render(conn, :user_response, user: deleted_user, msg: "Deleted")
      {:error, changeset} -> render(conn, :error_handler, error: format_error_changeset(changeset))
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
