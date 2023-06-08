defmodule BlogWeb.CommentController do
  use BlogWeb, :controller

  alias Blog.Topics
  alias Blog.Comments
  # import BlogWeb.FormatError
  action_fallback BlogWeb.FallbackController
  plug :is_owner when action in [:edit, :delete]

  def create(conn, %{"blog_id" => blog_id, "comment" => comment}) do
    user = conn.assigns.user
    with {id, _} <- Integer.parse(blog_id),
    %Blog.Model.Topic{} = blog <- Topics.get_blog_by_id(id),
    {:ok, inserter_comment} <- Comments.insert_comment(blog, comment, user.id)
    do
      render(conn, :show, comment: inserter_comment, blog: blog)
    end
  end


  def edit(conn, %{"comment" => comment_details}) do
    current_comment = conn.assigns.comment
    with {:ok, updated_comment} <- Comments.update_comment(current_comment, comment_details) do
      render(conn, :show, comment: updated_comment)
    end
  end

  def delete(conn, _params) do
    comment = conn.assigns.comment
    with {:ok, deleted_comment} <- Comments.delete_comment(comment) do
      render(conn, :show, comment: deleted_comment)
    end
  end

  def is_owner(conn, _params) do
    user = conn.assigns.user
    comment_id = conn.params["comment_id"]
    comment_id = String.to_integer(comment_id)
    case Comments.get_comment_by_id(comment_id) do
      nil ->
        conn
        |> resp(404, "Not Found")
        |> halt()
      comment ->
        if comment.user_id == user.id do
          conn =
            conn
            |> assign(:comment, comment)


            conn
        else
          conn
          |> resp(403, "Forbidan")
          |> halt()
        end
    end
  end

end
