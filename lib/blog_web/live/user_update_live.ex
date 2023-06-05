defmodule BlogWeb.UserUpdateLive do
  use Phoenix.LiveView
  alias Phoenix.Token
  alias Blog.Users
  import Argon2


  def render(assigns) do
    ~L"""
      <div class="row">
        <form class="col s6" phx-submit="save" phx-change="validate" style="display: inline-block; margin-left: 25%;
            margin-right:25%; width: 50%; margin-top: 8%">
          <div class="row">
            <div class="input-field col s6">
              <input placeholder="Enter First Name" type="text" name="user_details[fname]" value= "<%= @user_details["fname"] %>" required>
              <%= if @fnameRequired do %>
                <span>Field is required</span>
              <% end %>
            </div>
            <div class="input-field col s6">
              <input type="text" placeholder="Enter Last Name" name="user_details[lname]" value= "<%= @user_details["lname"]%>" required>
              <%= if @lnameRequired do %>
                <span>Field is required</span>
              <% end %>
            </div>
            <div class="input-field col s6">
              <input type="email" placeholder="Enter Email" name="user_details[email]" value= "<%= @user_details["email"]%>" required>
              <%= if @emailRequired do %>
                <span>enter valid email</span>
              <% end %>
            </div>
            <div class="input-field col s6">
              <input type="password"  placeholder="Enter Current Password" name="user_details[oldPassword]">
              <%= if @oldPassRequired do %>
                <span>inValid Password</span>
              <% end %>
            </div>
            <div class="input-field col s6">
              <input type="password"  placeholder="Enter New Password" name="user_details[newPassword]">
              <%= if @newPassRequired do %>
                <span>Field is required</span>
              <% end %>
            </div>
          </div>
            <button class="btn waves-effect waves-light" type="submit" name="action" >update</button>
            <a class="btn waves-effect waves-light" type="button" href="/auth/delete">delete account</a>
        </form>

      </div>
    """
  end

  def mount(_, %{"auth_token" => auth_token}, socket) do
    {:ok, user_id} = Token.verify(BlogWeb.Endpoint, "somekey", auth_token)
    user = Users.get_user_by_id(user_id)
    user_details = generate_user_params(user)
    {:ok, socket
    |> assign(user_details: user_details, user: user, fnameRequired: false, lnameRequired: false, emailRequired: false, oldPassRequired: false, newPassRequired: false)}
  end

  def handle_event("save", %{"user_details" => %{"oldPassword" => password} = user_details}, socket) do
    user = socket.assigns.user
    if is_new_password_set?(user_details) do
      case verify_pass(password, user.password) do
        true ->
          encrypted_password = hash_pwd_salt(user_details["newPassword"])
          case Users.updated_user(user, Map.put(user_details, "password", encrypted_password)) do
            {:ok, _changeset} ->
              {:noreply, socket |> put_flash(:info, "New Password is set") |> redirect(to: "/auth/signout")}
            {:error, _changeset} ->
              {:noreply, socket |> put_flash(:error, "Something went wrong") |> redirect(to: "/auth/profile")}
          end
        _ -> {:noreply, socket |> put_flash(:error, "invalid password") |> redirect(to: "/auth/profile")}
      end
    else
      case Users.updated_user(user, Map.put(user_details, "newPassword", user.password)) do
        {:ok, _changeset} ->
          {:noreply, socket |> put_flash(:info, "Updated") |> redirect(to: "/auth/profile")}
        {:error, _changeset} -> {:noreply, socket |> put_flash(:error, "Something went wrong") |> redirect(to: "/auth/profile")}
      end
    end
  end

  def handle_event("validate", %{"user_details" => user_details, "_target" => [_, cursor]}, socket) do
    cond do
      cursor == "fname" and String.length(user_details[cursor]) == 0 -> {:noreply, assign(socket, fnameRequired: true, user_details: user_details)}
      cursor == "fname" and String.length(user_details[cursor]) != 0 -> {:noreply, assign(socket, fnameRequired: false, user_details: user_details)}
      cursor == "lname" and String.length(user_details[cursor]) == 0 -> {:noreply, assign(socket, lnameRequired: true, user_details: user_details)}
      cursor == "lname" and String.length(user_details[cursor]) != 0 -> {:noreply, assign(socket, lnameRequired: false, user_details: user_details)}
      cursor == "email" and String.match?(user_details[cursor], ~r/@/) -> {:noreply, assign(socket, emailRequired: false, user_details: user_details)}
      cursor == "email" and !String.match?(user_details[cursor], ~r/@/) -> {:noreply, assign(socket, emailRequired: true, user_details: user_details)}
      cursor == "oldPassword" and String.length(user_details[cursor]) == 0 -> {:noreply, assign(socket, oldPassRequired: true, user_details: user_details)}
      cursor == "oldPassword" and String.length(user_details[cursor]) != 0 -> {:noreply, assign(socket, oldPassRequired: false, user_details: user_details)}
      cursor == "newPassword" and String.length(user_details[cursor]) == 0 -> {:noreply, assign(socket, newPassRequired: true, user_details: user_details)}
      cursor == "newPassword" and String.length(user_details[cursor]) != 0 -> {:noreply, assign(socket, newPassRequired: false, user_details: user_details)}
    end
    {:noreply, socket}
  end

  defp generate_user_params(user) do
    %{"fname" => user.fname, "lname" => user.lname, "email" => user.email, "oldPassword" => "", "newPassword" => ""}
  end

  defp is_new_password_set?(params) do
    if params["newPassword"] == "" do
      false
    else
      true
    end
  end
end
