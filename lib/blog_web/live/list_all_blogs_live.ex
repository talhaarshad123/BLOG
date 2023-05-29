defmodule BlogWeb.ListAllBlogsLive do
  use Phoenix.LiveView
  alias Phoenix.PubSub
  alias Blog.Topic
  alias Phoenix.Token
  alias Blog.Like


  def render(assigns) do
    ~L"""
      <h5>Topics</h5>
      <ul class="collection">
      <%= for topic <- @topics do %>

        <li class="collection-item">
          <a href="/blog/<%= topic.id %>/comment"><%= topic.title %></a>
          <%= if @authenticated and @user_id == topic.user_id do  %>
            <div class="right">
              <a href="/edit/<%= topic.id %>">Edit</a>
              <a href="/delete/<%= topic.id %>">Delete</a>
            </div>
          <% end %>

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
      <div class="fixed-action-btn">
      <a href="/new">
      <i class="material-icons">add</i>
      </a>
      </div>
    """
  end

  def mount(_, %{"auth_token" => auth_token}, socket) do
    topics = Topic.all_topics()
    case Token.verify(BlogWeb.Endpoint, "somekey", auth_token) do
      {:ok, user_id} ->
        PubSub.subscribe(Blog.PubSub, "likes")
        {:ok, socket |> assign(topics: topics, user_id: user_id, authenticated: true)}
      {:error, _} -> {:ok, socket |> put_flash(:error, "Authentication Error.") |> redirect(to: "/")}
    end
  end

  def mount(_, _, socket) do
    topics = Topic.all_topics()
    # PubSub.subscribe(Blog.PubSub, "likes")
    {:ok, socket |> assign(topics: topics, user_id: nil, authenticated: false)}
  end

  def handle_event("manage-like", %{"id" => blog_id}, socket) do
    user_id = socket.assigns.user_id
    blog_id = String.to_integer(blog_id)
    is_authenticated? = socket.assigns.authenticated
    if is_authenticated? do
      if !is_liked?(blog_id , user_id) do
        case Like.insert_like(blog_id, user_id) do
          {:ok, _changeset} ->
            Topic.get_blog_by_id(blog_id)
            |> Topic.update_number_of_likes(:inc)
            PubSub.broadcast(Blog.PubSub, "likes", {})
             {:noreply, socket}
          {:error, _reason} -> {:noreply, socket |> put_flash(:error, "Something went wrong") |> redirect(to: "/")}
        end
      else
        like = Like.get_like_by_blog_user(blog_id, user_id)
        case Like.delete_like(like.id) do
          {:ok, _} ->
            Topic.get_blog_by_id(blog_id)
            |> Topic.update_number_of_likes(:dec)
            PubSub.broadcast(Blog.PubSub, "likes", {})
            {:noreply, socket}
          {:error, _} -> {:noreply, socket |> put_flash(:error, "Something went wrong") |> redirect(to: "/")}
        end
      end
    else
      {:noreply, socket |> put_flash(:error, "Unauthroized") |> redirect(to: "/")}
    end
  end

  def handle_info(_msg, socket) do
    topics = Topic.all_topics()
    {:noreply, socket |> assign(topics: topics)}
  end


  defp is_liked?(blog_id, user_id) do
    case Like.get_like_by_blog_user(blog_id, user_id) do
      nil -> false
      _like -> true
    end
  end
end
