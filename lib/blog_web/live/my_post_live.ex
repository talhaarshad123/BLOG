defmodule BlogWeb.MyPostLive do
  use Phoenix.LiveView
  alias Phoenix.Token
  alias Blog.Topic


  def render(assigns) do
    ~L"""
    <h5>Topics</h5>
    <ul class="collection">
    <%= for topic <- @topics do %>
      <li class="collection-item">
        <a href="/blog/<%= topic.id %>/comment"><%= topic.title %></a>
          <div class="right">
            <a href="/edit/<%= topic.id %>">Edit</a>
            <a href="/delete/<%= topic.id %>">Delete</a>
          </div>

        <div class="center">
          <span>
            <%= topic.numberOfLikes %>
          </span>
          <a href="" phx-click="manage-like" phx-value-id="<%= topic.id %>">
            like
          </a>
        </div>
      </li>
    <% end %>
    </ul>
    <div>
    <%= if @page > 1 do %>
      <a class="waves-effect waves-light btn" phx-click="previous">back</a>
    <% end %>
      <%= case @topics do %>
      <% [] -> %>
        <a class="waves-effect waves-light btn disabled">next</a>
      <% _ ->  %>
        <a class="waves-effect waves-light btn" phx-click="next">next</a>
      <% end %>
    </div>
    """
  end

  def mount(_, %{"auth_token" => auth_token}, socket) do
    page = 1
    case Token.verify(BlogWeb.Endpoint, "somekey", auth_token) do
      {:ok, user_id} ->
        topics = Topic.get_user_posts(page, user_id)
        {:ok, socket |> assign(topics: topics, page: page, user_id: user_id)}
      {:error, _} -> {:ok, socket |> put_flash(:error, "Unauthorized") |> redirect(to: "/")}
    end
  end

  def mount(_, _, socket) do
    {:ok, socket |> put_flash(:error, "Unauthroized") |> redirect(to: "/")}
  end

  def handle_event("previous", _unsigned_params, socket) do
    current_page = socket.assigns.page
    user_id = socket.assigns.user_id
    current_page = current_page - 1
    topics = Topic.get_user_posts(current_page, user_id)
    {:noreply, socket |> assign(topics: topics, page: current_page)}
  end
  def handle_event("next", _unsigned_params, socket) do
    current_page = socket.assigns.page
    user_id = socket.assigns.user_id
    current_page = current_page + 1
    topics = Topic.get_user_posts(current_page, user_id)
    {:noreply, socket |> assign(topics: topics, page: current_page)}
  end
end
