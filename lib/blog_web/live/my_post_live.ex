defmodule BlogWeb.MyPostLive do
  use Phoenix.LiveView
  alias Phoenix.Token
  alias Blog.Topics
  alias Blog.Likes
  alias Phoenix.PubSub


  def render(assigns) do
    ~L"""
    <h5>Topics</h5>
    <ul class="collection">
    <%= for topic <- @topics do %>
      <li class="collection-item">
        <a href="/blog/<%= topic.id %>/comment"><%= topic.title %></a>
          <div class="right">
            <a href="/auth/edit/<%= topic.id %>">Edit</a>
            <a href="/auth/delete/<%= topic.id %>">Delete</a>
          </div>

        <div class="center">
          <span>
            <%= length(topic.likes) %>
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
    {:ok, user_id} = Token.verify(BlogWeb.Endpoint, "somekey", auth_token)
    topics = Topics.get_user_posts(page, user_id)
    {:ok, socket |> assign(topics: topics, page: page, user_id: user_id, authenticated: true)}
  end

  def handle_event("previous", _unsigned_params, socket) do
    current_page = socket.assigns.page
    user_id = socket.assigns.user_id
    current_page = current_page - 1
    topics = Topics.get_user_posts(current_page, user_id)
    {:noreply, socket |> assign(topics: topics, page: current_page)}
  end
  def handle_event("next", _unsigned_params, socket) do
    current_page = socket.assigns.page
    user_id = socket.assigns.user_id
    current_page = current_page + 1
    topics = Topics.get_user_posts(current_page, user_id)
    {:noreply, socket |> assign(topics: topics, page: current_page)}
  end

  def handle_event("manage-like", %{"id" => blog_id}, socket) do
    user_id = socket.assigns.user_id
    blog_id = String.to_integer(blog_id)
    is_authenticated? = socket.assigns.authenticated
    if is_authenticated? do
      if !is_liked?(blog_id , user_id) do
        case Likes.insert_like(blog_id, user_id) do
          {:ok, _changeset} ->
            PubSub.broadcast(Blog.PubSub, "likes", {})
             {:noreply, socket}
          {:error, _reason} -> {:noreply, socket |> put_flash(:error, "Something went wrong") |> redirect(to: "/")}
        end
      else
        like = Likes.get_like_by_blog_user(blog_id, user_id)
        case Likes.delete_like(like.id) do
          {:ok, _} ->
            PubSub.broadcast(Blog.PubSub, "likes", {})
            {:noreply, socket}
          {:error, _} -> {:noreply, socket |> put_flash(:error, "Something went wrong") |> redirect(to: "/")}
        end
      end
    else
      {:noreply, socket |> put_flash(:error, "Unauthroized") |> redirect(to: "/")}
    end
  end


  defp is_liked?(blog_id, user_id) do
    case Likes.get_like_by_blog_user(blog_id, user_id) do
      nil -> false
      _like -> true
    end
  end
end
