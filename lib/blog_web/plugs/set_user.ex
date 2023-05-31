defmodule BlogWeb.Plugs.SetUser do
  import Plug.Conn
  alias Blog.Users
  alias Phoenix.Token


  def init(_) do
  end

  def call(conn, _params) do
    token = get_session(conn, :auth_token)
    case Token.verify(BlogWeb.Endpoint, "somekey", token) do
      {:ok, user_id} ->
        case Users.get_user_by_id(user_id) do
          nil ->
            # IO.inspect(assign(conn, :user, nil))
            conn
          user ->
            assign(conn, :user, user)
        end
      {:error, _} -> conn

    end
  end
end
