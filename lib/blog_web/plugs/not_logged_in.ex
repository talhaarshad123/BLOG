defmodule BlogWeb.Plugs.NotLoggedIn do
  import Plug.Conn
  import Phoenix.Controller


  def init(_) do
  end

  def call(conn, _params) do
    case get_session(conn, :auth_token) do
      nil -> conn
      _ ->
        conn
        |> redirect(to: "/")
        |> halt()
    end
  end
end
