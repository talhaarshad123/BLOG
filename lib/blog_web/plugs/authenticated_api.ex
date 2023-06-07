defmodule BlogWeb.Plugs.AuthenticatedApi do
  import Plug.Conn
  alias Phoenix.Token
  alias Blog.Users


  def init(_) do
  end

  def call(%Plug.Conn{params: %{"token" => token}} = conn, _params) do
    case Token.verify(BlogWeb.Endpoint, "somekey", token) do
      {:ok, user_id} ->
        case Users.get_user_by_id(user_id) do
          nil ->
            conn = conn
            |> resp(403, "Forbidan")
            |> halt()

            conn
          user ->
            conn = conn
            |> assign(:user, user)

            conn
        end
      {:error, _} ->
        conn
        |> resp(403, "Forbidan")
    end
  end

end
