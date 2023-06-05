defmodule BlogWeb.NewBlogLive do
  use Phoenix.LiveView
  alias Phoenix.Token
  alias Blog.Topics
  alias Phoenix.PubSub

  def render(assigns) do
    ~L"""
    <div class="row">
    <form class="col s6" phx-submit="save" phx-change="validate" style="display: inline-block; margin-left: 25%;
        margin-right:25%; width: 50%; margin-top: 8%">
      <div class="row">
        <div class="input-field col s6">
          <input placeholder="Enter Title" type="text" name="blog_details[title]" value= "<%= @blog_details["title"] %>" >
          <%= if @titleRequired do %>
            <span>Field is required</span>
          <% end %>
        </div>
        <div class="input-field col s6">
          <input type="text" placeholder="Enter description" name="blog_details[description]" value="<%= @blog_details["description"]%>" >
          <%= if @descripRequired do %>
            <span>Field is required</span>
          <% end %>
        </div>
      </div>
        <%= if @authenticated do %>
          <button class="btn waves-effect waves-light" type="submit" name="action" >Submit</button>
        <% end %>
    </form>
    </div>
    """
  end

  def mount(_, %{"auth_token" => auth_token}, socket) do
    {:ok, user_id} = Token.verify(BlogWeb.Endpoint, "somekey", auth_token)
    {:ok, socket
      |> assign(blog_details: %{"title" => "", "description" => ""}, titleRequired: false, descripRequired: false, authenticated: true, user_id: user_id)}
  end
  def handle_event("save", %{"blog_details" => blog_details}, socket) do
    is_authenticated? = socket.assigns.authenticated
    user_id = socket.assigns.user_id
    if is_authenticated? do
      case Topics.create_blog(blog_details, user_id) do
        {:ok, topic} ->
          PubSub.broadcast_from(Blog.PubSub, self(), "topics", {:topic, topic})
          {:noreply, socket |> put_flash(:info, "Blog created.") |> redirect(to: "/")}
        {:error, _reason} ->
          {:noreply, socket |> put_flash(:error, "Oops Something went wrong") |> redirect(to: "/new")}
      end
    end
  end
  def handle_event("validate", %{"blog_details" => blog_details, "_target" => [_, cursor]}, socket) do
    cond do
      cursor == "title" and String.length(blog_details[cursor]) == 0 -> {:noreply, assign(socket, titleRequired: true, blog_details: blog_details)}
      cursor == "title" and String.length(blog_details[cursor]) != 0 -> {:noreply, assign(socket, titleRequired: false, blog_details: blog_details)}
      cursor == "description" and String.length(blog_details[cursor]) == 0 -> {:noreply, assign(socket, descripRequired: true, blog_details: blog_details)}
      cursor == "description" and String.length(blog_details[cursor]) != 0 -> {:noreply, assign(socket, descripRequired: false, blog_details: blog_details)}
    end
  end
end
