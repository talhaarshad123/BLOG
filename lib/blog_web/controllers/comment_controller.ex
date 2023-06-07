defmodule BlogWeb.CommentController do
  use BlogWeb, :controller

  alias Blog.Topics
  alias Blog.Comments
  import BlogWeb.FormatError

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
end
