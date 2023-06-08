defmodule BlogWeb.BlogController do
  use BlogWeb, :controller

  alias Blog.Topics
  alias Blog.Comments
  # import BlogWeb.FormatError

  action_fallback BlogWeb.FallbackController

  plug :is_owner when action in [:edit, :delete]

  @per_page 2


  def index(conn, %{"page" => page_number}) do
    with {page, _} <- Integer.parse(page_number),
         blogs <- Topics.all_topics(page)
    do
      render(conn, :show, blogs: Enum.slice(blogs, 0, @per_page))
    end
  end

  def show(conn, %{"id" => blog_id}) do
    with {id, _} <- Integer.parse(blog_id),
      %Blog.Model.Topic{} = blog <- Topics.get_blog_by_id(id)
    do
      render(conn, :show, blog: blog)
    end
  end

  def blog_comments(conn, %{"id" => blog_id}) do
    with {id, _} <- Integer.parse(blog_id),
         %Blog.Model.Topic{} = blog_comments <- Comments.get_comments_by_blog(id)
    do
      render(conn, :show, blog_comments: blog_comments)
    end
  end

  def create(conn, %{"blog" => blog_details}) do
    user = conn.assigns.user
    with {:ok, blog} <- Topics.create_blog(blog_details, user.id) do
      render(conn, :show, blog: blog)
    end
  end

  def edit(conn, %{"blog" => blog_details}) do
    blog = conn.assigns.blog
    with {:ok, updated_blog} <- Topics.update_blog(blog, blog_details) do
      render(conn, :show, blog: updated_blog)
    end
  end

  def delete(conn, _params) do
    blog = conn.assigns.blog
    with {:ok, deleted_blog} <- Topics.delete_blog(blog.id) do
      render(conn, :show, blog: deleted_blog)
    end
  end



  def is_owner(conn, _params) do
    user = conn.assigns.user
    blog_id = conn.params["id"]
    with {id, _} <- Integer.parse(blog_id),
    %Blog.Model.Topic{} = blog <- Topics.get_blog_by_id(id),
    true <- blog.user_id == user.id
     do
      conn =
        conn
        |> assign(:blog, blog)
      conn
    end
  end


end
