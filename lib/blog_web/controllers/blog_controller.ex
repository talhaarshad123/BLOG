defmodule BlogWeb.BlogController do
  use BlogWeb, :controller

  alias Blog.Topics
  alias Blog.Comments
  import BlogWeb.FormatError

  plug :is_owner when action in [:edit, :delete]

  @per_page 2


  def index(conn, %{"page" => page_number}) do
    page_number = String.to_integer(page_number)
    blogs = Topics.all_topics(page_number)
    cond do
      length(blogs) > @per_page -> render(conn, :index, blogs: Enum.slice(blogs, 0, @per_page))
      true -> render(conn, :show, blogs: blogs)
    end

  end

  def show(conn, %{"id" => blog_id}) do
    blog_id = String.to_integer(blog_id)
    case Topics.get_blog_by_id(blog_id) do
      nil -> render(conn, :show, blog: [])
      blog -> render(conn, :show, blog: blog)
    end
  end

  def blog_comments(conn, %{"id" => blog_id}) do
    blog_id = String.to_integer(blog_id)
    case Comments.get_comments_by_blog(blog_id) do
      nil -> render(conn, :error_handler, error: "bad request")
      blog_comments ->
        render(conn, :show, blog_comments: blog_comments)
    end
  end

  def create(conn, %{"blog" => blog_details}) do
    user = conn.assigns.user
    case Topics.create_blog(blog_details, user.id) do
      {:ok, blog} -> render(conn, :show, blog: blog)
      {:error, changeset} ->
        render(conn, :error_handler, error: format_error_changeset(changeset))
    end
  end

  def edit(conn, %{"blog" => blog_details}) do
    blog = conn.assigns.blog
    case Topics.update_blog(blog, blog_details) do
      {:ok, updated_blog} -> render(conn, :show, blog: updated_blog)
      {:error, changeset} -> render(conn, :error_handler, error: format_error_changeset(changeset))
    end
  end

  def delete(conn, _params) do
    blog = conn.assigns.blog
    case Topics.delete_blog(blog.id) do
      {:ok, deleted_blog} -> render(conn, :show, blog: deleted_blog)
      {:error, changeset} -> render(conn, :error_handler, error: format_error_changeset(changeset))
    end
  end



  def is_owner(conn, _params) do
    user = conn.assigns.user
    blog_id = conn.params["id"]
    blog_id = String.to_integer(blog_id)
    case Topics.get_blog_by_id(blog_id) do
      nil ->
        conn
        |> resp(404, "Not Found")
        |> halt()
      blog ->
        cond do
          blog.user_id == user.id ->
            conn = conn
            |> assign(:blog, blog)

            conn
          true ->
            conn
            |> resp(403, "Forbidan")
        end
    end
  end


end
