defmodule BlogWeb.LikeController do
  use BlogWeb, :controller

  alias Blog.Likes
  alias Blog.Topics
  import BlogWeb.FormatError


  def like(conn, %{"blog_id" => blog_id}) do
    blog_id = String.to_integer(blog_id)
    user = conn.assigns.user
    if does_exist?(blog_id, user.id) do
      IO.inspect("DOES EXSIT")
      resp(conn, 403, "Forbidan")
    else
      case Topics.get_blog_by_id(blog_id) do
        nil -> resp(conn, 404, "NOT FOUND")
        _ ->
          case Likes.insert_like(blog_id, user.id) do
            {:ok, inserted_like} -> render(conn, :show, like: inserted_like)
            {:error, changeset} -> render(conn, :error_handler, error: format_error_changeset(changeset))
          end
      end
    end
  end

  def unlike(conn, %{"blog_id" => blog_id}) do
    blog_id = String.to_integer(blog_id)
    user = conn.assigns.user
    if does_exist?(blog_id, user.id) do
      found_like = Likes.get_like_by_blog_user(blog_id, user.id)
      case Likes.delete_like(found_like) do
        {:ok, deleted_like} -> render(conn, :show, like: deleted_like)
        {:error, changeset} -> render(conn, :error_handler, error: format_error_changeset(changeset))
      end
    else
      resp(conn, 404, "NOT FOUND")
    end
  end

  defp does_exist?(blog_id, user_id) do
    case Likes.get_like_by_blog_user(blog_id, user_id) do
      nil -> false
      _ -> true
    end
  end

end
