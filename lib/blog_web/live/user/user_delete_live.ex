defmodule BlogWeb.User.UserDeleteLive do
  use Phoenix.LiveView
  alias Phoenix.Token
  alias Blog.Users
  import Argon2


  def render(assigns) do
    ~L"""
      <div class="row">
        <form class="col s6" phx-submit="save" style="display: inline-block; margin-left: 25%;
            margin-right:25%; width: 50%; margin-top: 8%">
          <div class="row">
            <div class="input-field col s6">
              <input type="password"  placeholder="Enter Current Password" name="pass" required>
            </div>
          </div>
            <button class="btn waves-effect waves-light" type="submit" name="action" >delete account</button>
        </form>
      </div>
    """
  end

  def mount(_, %{"auth_token" => auth_token}, socket) do
    {:ok, user_id} = Token.verify(BlogWeb.Endpoint, "somekey", auth_token)
    user = Users.get_user_by_id(user_id)
    {:ok, socket |> assign(user: user)}
  end

  def handle_event("save", %{"pass" => password}, socket) do
    user = socket.assigns.user
    case verify_pass(password, user.password) do
      true ->
        case Users.delete_user(user) do
          {:ok, _} ->
            {:noreply, socket |> put_flash(:info, "Account is deleted") |> redirect(to: "/auth/signout")}
          {:error, _} ->
            {:noreply, socket |> put_flash(:error, "Something went wrong") |> redirect(to: "/auth/delete")}
        end
      _ -> {:noreply, socket |> put_flash(:error, "Invalid Password") |> redirect(to: "/auth/delete")}
    end
  end

end
