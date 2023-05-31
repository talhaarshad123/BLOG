defmodule BlogWeb.ConfigUserSessionController do
  use BlogWeb, :controller
  alias Phoenix.Token


  def login_user(conn, %{"token" => token}) do
    case Token.verify(BlogWeb.Endpoint, "somekey", token) do
      {:ok, _user_id} ->
        put_session(conn, :auth_token, token)
        |> redirect(to: "/")
      {:error, :invalid} -> redirect(conn, to: "/signup")
    end
  end

  def logout_user(conn, _params) do
    conn
    |> configure_session(drop: true)
    |> redirect(to: "/")
  end



end
