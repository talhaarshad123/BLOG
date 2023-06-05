defmodule BlogWeb.DeleteCommentLive do
  use Phoenix.LiveView
  alias Phoenix.Token
  alias Blog.Comments

  def render(assigns) do
    ~L"""
    """
  end

  def mount(%{"id" => comment_id}, %{"auth_token" => auth_token}, socket) do
    comment_id = String.to_integer(comment_id)
    comment = Comments.get_comment_by_id(comment_id)
    blog_id = comment.topic_id
    {:ok, user_id} = Token.verify(BlogWeb.Endpoint, "somekey", auth_token)
    if is_owner?(comment, user_id) do
      case Comments.delete_comment(comment) do
        {:ok, _} -> {:ok, socket |> put_flash(:info, "Comment deleted.") |> redirect(to: "/blog/#{blog_id}/comment")}
        {:error, _} -> {:ok, socket |> put_flash(:error, "Something went wrong.") |> redirect(to: "/")}
      end
    else
      {:ok, socket |> put_flash(:error, "Unauthroized.") |> redirect(to: "/")}
    end
  end

  def is_owner?(comment, user_id) do
    cond do
      comment.user_id == user_id -> true
      true -> false
    end
  end

end
