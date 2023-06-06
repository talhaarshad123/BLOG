defmodule BlogWeb.Comment.AddCommentLive do
  use Phoenix.LiveView
  alias Phoenix.Token
  alias Blog.Comments
  alias Phoenix.PubSub
  alias Blog.Users

  def render(assigns) do
    ~L"""
    <h5> <%= @blog.title %> </h5>
    <h4> <%= @blog.description %> </h4>
    <form class="form-control" phx-submit="save">
    <div class="input-field">
    <input class="meterialize-textarea" placeholder="Enter Comment" required name="content" id="comment-input">
    <button class="btn" type="submit">Comment</button>
    </form>
    <div>
    <ul class="collection" id="comments-id" phx-hook="Comments">
    <%= for comment <- @blog.comments do %>
      <li class="collection-item"> <%= comment.content %>

      <%= if @is_authenticated? and comment.user_id === @user_id do %>
        <div class="right">
          <a href="/auth/edit/<%= comment.id %>/comment">Edit</a>
          <a href="/auth/delete/<%= comment.id %>/comment">delete</a>
        </div>
      <% end %>
      <div class="secondary-content">
        <%= comment.user.fname %>
      </div>
      </li>
    <% end %>
    </ul>
    </div>
    </div>
    """
  end

  def mount(%{"blog_id" => blog_id}, %{"auth_token" => auth_token}, socket) do
    blog_id = String.to_integer(blog_id)
    {:ok, user_id} = Token.verify(BlogWeb.Endpoint, "somekey", auth_token)
    blog_comments = Comments.get_comments_by_blog(blog_id)
    PubSub.subscribe(Blog.PubSub, "comment:#{blog_id}")
    {:ok, socket |> assign(blog: blog_comments, is_authenticated?: true, user_id: user_id)}
  end

  def mount(%{"blog_id" => blog_id}, _session, socket) do
    blog_id = String.to_integer(blog_id)
    blog_comments = Comments.get_comments_by_blog(blog_id)
    PubSub.subscribe(Blog.PubSub, "comment:#{blog_id}")
    {:ok, socket |> assign(blog: blog_comments, is_authenticated?: false, user_id: nil)}
  end

  def mount(_, _, socket) do
    {:ok, socket |> put_flash(:error, "Not Allowed") |> redirect(to: "/")}
  end

  def handle_event("save", params, socket) do
    user_id = socket.assigns.user_id
    blog = socket.assigns.blog
    cond do
      socket.assigns.is_authenticated?->
        case Comments.insert_comment(blog, params, user_id) do
          {:ok, comment} ->
            broadcast_comment(comment)
            {:noreply, socket}
          {:error, _reason} ->
            {:noreply, socket |> put_flash(:error, "Something went wrong") |> redirect(to: "/")}
        end
        true ->
          {:noreply, socket |> put_flash(:error, "You must login first.") |> redirect(to: "/blog/#{blog.id}/comment")}
    end
  end

  def handle_info({:comment, comment}, socket) do
    payload = generate_payload(comment)
    {:noreply, socket |> push_event("update-comments", payload)}
  end

  defp broadcast_comment(comment) do
    PubSub.broadcast(Blog.PubSub, "comment:#{comment.topic_id}", {:comment, comment})
  end


  defp generate_payload(comment) do
    user = Users.get_user_by_id(comment.user_id)
    %{
      content: comment.content,
      id: comment.id,
      name: user.fname
    }
  end
end
