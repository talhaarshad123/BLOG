defmodule BlogWeb.Plugs.RequireAuth do
  import Plug.Conn
  import Phoenix.Controller
  alias Phoenix.Token



  def init(_) do
  end


  def call(conn, _params) do
    case get_session(conn, :auth_token) do
      nil ->
        conn
        |> put_flash(:error, "Login Required")
        |> redirect(to: "/")
        |> halt()
      token ->
        case Token.verify(BlogWeb.Endpoint, "somekey", token) do
          {:ok, _user_id} -> conn
          {:error, _} ->
            conn |> put_flash(:error, "Unauthroized") |> redirect(to: "/") |> halt()
        end
    end
  end
end
