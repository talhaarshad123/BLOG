defmodule BlogWeb.ListAllBlogsLive do
  use Phoenix.LiveView
  alias Phoenix.PubSub
  alias Blog.Topics
  alias Phoenix.Token
  alias Blog.Likes


  def render(assigns) do
    ~L"""
      <h5>Topics</h5>
      <ul class="collection" id="topics" phx-hook="TopicHook">
      <%= for topic <- @topics do %>
        <li class="collection-item" id="topic<%= topic.id %>">
          <a href="/blog/<%= topic.id %>/comment"><%= topic.title %></a>
          <%= if @authenticated and @user_id == topic.user_id do  %>
            <div class="right">
              <a href="/auth/edit/<%= topic.id %>">Edit</a>
              <a href="/auth/delete/<%= topic.id %>">Delete</a>
            </div>
          <% end %>

          <div class="center">
            <span>
              <%= length(topic.likes) %>
            </span>
              <a href="#" phx-click="manage-like" phx-value-id="<%= topic.id %>">
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
      <div class="fixed-action-btn">
      <a href="/auth/new">
      <i class="material-icons">add</i>
      </a>
      </div>
    """
  end



  def mount(_, %{"auth_token" => auth_token}, socket) do
    topics = Topics.all_topics(1)
    {:ok, user_id} = Token.verify(BlogWeb.Endpoint, "somekey", auth_token)
    PubSub.subscribe(Blog.PubSub, "topics")
    PubSub.subscribe(Blog.PubSub, "likes")
    {:ok, socket |> assign(topics: topics, user_id: user_id, authenticated: true, page: 1)}
  end

  def mount(_, _, socket) do
    topics = Topics.all_topics(1)
    # PubSub.subscribe(Blog.PubSub, "likes")
    {:ok, socket |> assign(topics: topics, user_id: nil, authenticated: false, page: 1)}
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

  def handle_event("previous", _unsigned_params, socket) do
    current_page = socket.assigns.page
    current_page = current_page - 1
    topics = Topics.all_topics(current_page)
    {:noreply, socket |> assign(topics: topics, page: current_page)}
  end
  def handle_event("next", _unsigned_params, socket) do
    current_page = socket.assigns.page
    current_page = current_page + 1
    topics = Topics.all_topics(current_page)
    {:noreply, socket |> assign(topics: topics, page: current_page)}
  end

  def handle_info({:blog, blog}, socket) do
    payload = %{blog_id: blog.id}
    {:noreply, socket |> push_event("delete-topic", payload)}
  end
  def handle_info({:topic, topic}, socket) do
    payload = generate_payload_topic(topic)
    current_page = socket.assigns.page
    if current_page === 1 do
      {:noreply, socket |> push_event("new-topic", payload)}
    else
      {:noreply, socket}
    end

  end

  def handle_info(_msg, socket) do
    topics = Topics.all_topics(1)
    {:noreply, socket |> assign(topics: topics)}
  end


  defp is_liked?(blog_id, user_id) do
    case Likes.get_like_by_blog_user(blog_id, user_id) do
      nil -> false
      _like -> true
    end
  end

  defp generate_payload_topic(topic) do
    %{
      topic_id: topic.id,
      title: topic.title,
      user_id: topic.user_id
    }
  end
  def is_owner?(topic_id, user_id) do
    case Topics.get_blog_by_id(topic_id) do
      nil -> false
      topic_changetset ->
        if topic_changetset.user_id == user_id do
          true
        else
          false
        end
    end
  end
end
