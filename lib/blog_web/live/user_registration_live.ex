defmodule BlogWeb.UserRegistrationLive do
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
              <input placeholder="Enter First Name" type="text" name="user_details[fname]" value= "<%= @user_details["fname"] %>" >
              <%= if @fnameRequired do %>
                <span>Field is required</span>
              <% end %>
            </div>
            <div class="input-field col s6">
              <input type="text" placeholder="Enter Last Name" name="user_details[lname]" value= "<%= @user_details["lname"]%>" >
              <%= if @lnameRequired do %>
                <span>Field is required</span>
              <% end %>
            </div>
            <div class="input-field col s6">
              <input type="email" placeholder="Enter Email" name="user_details[email]" value= "<%= @user_details["email"]%>" >
              <%= if @emailRequired do %>
                <span>!enter valid email</span>
              <% end %>
            </div>
            <div class="input-field col s6">
              <input type="password"  placeholder="Enter Password" name="user_details[password]" value= "<%= @user_details["password"]%>" >
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

  def mount(_, %{"auth_token" => token}, socket) do
    case Token.verify(BlogWeb.Endpoint, "somekey", token) do
      {:ok, _user_id} -> {:ok, socket |> redirect(to: "/")}
      {:error, :invalid} -> {:ok, assign(socket, user_details: %{"fname" => "", "lname" => "", "email" => "", "password" => ""}, fnameRequired: false, lnameRequired: false, emailRequired: false, passRequired: false)}
    end
  end

  def mount(_, _, socket) do
    {:ok, assign(socket, user_details: %{"fname" => "", "lname" => "", "email" => "", "password" => ""}, fnameRequired: false, lnameRequired: false, emailRequired: false, passRequired: false)}
  end

  def handle_event("save", %{"user_details" => %{"password" => password} = user_details}, socket) do
    encryted_password = hash_pwd_salt(password)
    user_with_encrypted_pass = Map.put(user_details, "password", encryted_password)
    case Users.create_user(user_with_encrypted_pass) do
      {:emailError, _user} ->
        {:noreply, redirect(put_flash(socket, :error, "Email already exsit"), to: "/signup")}
      {:ok, changeset} ->
        user_token = Token.sign(BlogWeb.Endpoint, "somekey", changeset.id)
        {:noreply, socket |>
        put_flash(:info, "User is created.") |> redirect(to: "/login/#{user_token}")}
      {:error, _reason} ->
        {:noreply, redirect(put_flash(socket, :error, "Oops! something went wrong."), to: "/signup")}
    end
    # {:noreply, assign(socket, user: user)}
  end
  def handle_event("validate", %{"user_details" => user_details, "_target" => [_, cursor]}, socket) do
    cond do
      cursor == "fname" and String.length(user_details[cursor]) == 0 -> {:noreply, assign(socket, fnameRequired: true, user_details: user_details)}
      cursor == "fname" and String.length(user_details[cursor]) != 0 -> {:noreply, assign(socket, fnameRequired: false, user_details: user_details)}
      cursor == "lname" and String.length(user_details[cursor]) == 0 -> {:noreply, assign(socket, lnameRequired: true, user_details: user_details)}
      cursor == "lname" and String.length(user_details[cursor]) != 0 -> {:noreply, assign(socket, lnameRequired: false, user_details: user_details)}
      cursor == "email" and String.match?(user_details[cursor], ~r/@/) -> {:noreply, assign(socket, emailRequired: false, user_details: user_details)}
      cursor == "email" and !String.match?(user_details[cursor], ~r/@/) -> {:noreply, assign(socket, emailRequired: true, user_details: user_details)}
      cursor == "password" and String.length(user_details[cursor]) == 0 -> {:noreply, assign(socket, passRequired: true, user_details: user_details)}
      cursor == "password" and String.length(user_details[cursor]) != 0 -> {:noreply, assign(socket, passRequired: false, user_details: user_details)}
    end
  end
end
