defmodule BlogWeb.UserAuthenticationLive do
  use Phoenix.LiveView
  alias Blog.Users
  import Argon2
  alias Phoenix.Token


  def render(assigns) do
    ~L"""
    <div class="row">
      <form class="col s6" phx-submit="save" phx-change="validate" style="display: inline-block; margin-left: 25%;
      margin-right:25%; width: 50%; margin-top: 8%">
        <div class="row">
          <div class="input-field col s6">
            <input type="email" placeholder="Enter Email" name="user_details[email]" value= "<%= @user_details["email"]%>" required>
            <%= if @emailRequired do %>
              <span>enter valid email</span>
            <% end %>
          </div>
          <div class="input-field col s6">
            <input type="password"  placeholder="Enter Password" name="user_details[password]" value= "<%= @user_details["password"]%>" required>
            <%= if @passRequired do %>
              <span>Field is required</span>
            <% end %>
          </div>
        </div>
        <button class="btn waves-effect waves-light" type="submit" name="action" >Submit</button>
      </form>
    </div>
    """
  end

  def mount(_, %{"auth_token" => auth_token}, socket) do
    case Token.verify(BlogWeb.Endpoint, "somekey", auth_token) do
      {:ok, _user_id} -> {:ok, socket |> redirect(to: "/")}
      {:error, _} -> {:ok, assign(socket, user_details: %{"email" => "", "password" => ""}, emailRequired: false, passRequired: false)}
    end
  end

  def mount(_, _, socket) do
    {:ok, assign(socket, user_details: %{"email" => "", "password" => ""}, emailRequired: false, passRequired: false)}
  end

  def handle_event("validate", %{"user_details" => user_details, "_target" => [_, cursor]}, socket) do
    cond do
      cursor == "email" and String.match?(user_details[cursor], ~r/@/) -> {:noreply, assign(socket, emailRequired: false, user_details: user_details)}
      cursor == "email" and !String.match?(user_details[cursor], ~r/@/) -> {:noreply, assign(socket, emailRequired: true, user_details: user_details)}
      cursor == "password" and String.length(user_details[cursor]) == 0 -> {:noreply, assign(socket, passRequired: true, user_details: user_details)}
      cursor == "password" and String.length(user_details[cursor]) != 0 -> {:noreply, assign(socket, passRequired: false, user_details: user_details)}
    end
  end

  def handle_event("save", %{"user_details" => %{"password" => password} = user_details }, socket) do
    case Users.get_user_by_email(user_details["email"]) do
      nil ->
        {:noreply, socket |> put_flash(:error, "User does not exist.") |> redirect(to: "/login")}
      user_changeset ->
        case verify_pass(password, user_changeset.password) do
          true ->
            token = Token.sign(BlogWeb.Endpoint, "somekey", user_changeset.id)
            {:noreply, socket |> redirect(to: "/login/#{token}")}
          false -> {:noreply, socket |> put_flash(:error, "invalid email or password.") |> redirect(to: "/login")}
        end
    end
  end

end
