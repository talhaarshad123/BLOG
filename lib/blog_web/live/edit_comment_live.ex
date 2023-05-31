defmodule BlogWeb.EditCommentLive do
  use Phoenix.LiveView
  alias Blog.Comments
  alias Phoenix.Token


  def render(assigns) do
    ~L"""
      <div class="row">
        <form class="col s6" phx-submit="save" style="display: inline-block; margin-left: 25%;
        margin-right:25%; width: 50%; margin-top: 8%">
        <div class="row">
        <div class="input-field col s6">
          <input type="text" placeholder="Enter Title" name="content" value= "<%= @comment.content %>" required >
        </div>
        </div>
        <button class="btn waves-effect waves-light" type="submit" name="action" >Save</button>
        </form>
      </div>
    """
  end

  def mount(%{"id" => comment_id}, %{"auth_token" => auth_token}, socket) do
    comment_id = String.to_integer(comment_id)
    comment = Comments.get_comment_by_id(comment_id)
    {:ok, user_id} = Token.verify(BlogWeb.Endpoint, "somekey", auth_token)
    if is_owner?(comment, user_id) do
      {:ok, socket |> assign(comment: comment)}
    else
      {:ok, socket |> put_flash(:error, "Unauthroized") |> redirect(to: "/")}
    end
  end
  def handle_event("save", %{"content" => content}, socket) do
    comment = socket.assigns.comment
    blog_id = socket.assigns.comment.topic_id
    case Comments.update_comment(comment, content) do
      {:ok, _changeset} -> {:noreply, socket |> put_flash(:info, "Updated.") |> redirect(to: "auth/blog/#{blog_id}/comment")}
      {:error, _changeset} -> {:noreply, socket |> put_flash(:error, "Something went wrong.") |> redirect(to: "auth/edit/#{comment.id}/comment")}

    end
  end

  defp is_owner?(comment, user_id) do
    cond do
      comment.user_id === user_id -> true
      true -> false
    end
  end
end
