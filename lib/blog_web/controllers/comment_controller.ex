defmodule BlogWeb.CommentController do
  use BlogWeb, :controller

  alias Blog.Topics
  alias Blog.Comments
  import BlogWeb.FormatError
  plug :is_owner when action in [:edit, :delete]

  def create(conn, %{"blog_id" => blog_id, "comment" => comment}) do
    is_authenticated? = conn.assigns.is_authenticated?
    if is_authenticated? do
      blog_id = String.to_integer(blog_id)
      user = conn.assigns.user
      case Topics.get_blog_by_id(blog_id) do
        nil -> render(conn, :error_handler, error: "Not Found")
        blog ->
          case  Comments.insert_comment(blog, comment, user.id) do
            {:ok, comment} -> render(conn, :new, comment: comment, blog: blog)
            {:error, changeset} -> render(conn, :error_handler, error: format_error_changeset(changeset))
          end
      end
    end
  end


  def edit(conn, %{"comment" => comment_details}) do
    current_comment = conn.assigns.comment
    case Comments.update_comment(current_comment, comment_details) do
      {:ok, updated_comment} -> render(conn, :show, comment: updated_comment)
      {:error, changeset} -> render(conn, :error_handler, error: format_error_changeset(changeset))
    end
  end

  def delete(conn, _params) do
    comment = conn.assigns.comment
    case Comments.delete_comment(comment) do
      {:ok, deleted_comment} -> render(conn, :show, comment: deleted_comment)
      {:error, changeset} -> render(conn, :error_handler, error: format_error_changeset(changeset))
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
