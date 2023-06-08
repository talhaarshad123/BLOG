defmodule BlogWeb.BlogJSON do

  def show(%{blog_comments: blog_comments}) do
    %{
      id: blog_comments.id,
      title: blog_comments.title,
      comments: Enum.map(blog_comments.comments, fn comment -> %{id: comment.id, title: comment.content} end)
    }
  end

  def show(%{blogs: blogs}) do
   %{data: Enum.map(blogs, fn blog -> data(blog) end)}
  end

  def show(%{blog: blog}) do
    data(blog)
  end

  defp data(blog) do
    %{
      id: blog.id,
      title: blog.title,
      description: blog.description
    }
  end

  def error_handler(%{error: error_details}) do
    %{details: error_details}
  end
end
