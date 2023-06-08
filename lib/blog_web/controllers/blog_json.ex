defmodule BlogWeb.BlogJSON do

  def index(%{blogs: blogs}) do
    %{data: (for blog <- blogs, do: show(blog))}
  end

  def show(%{blog_comments: blog_comments}) do
    %{
      id: blog_comments.id,
      title: blog_comments.title,
      comments: (for comment <- blog_comments.comments, do: %{id: comment.id, title: comment.content})
    }
  end

  def show(%{blogs: blogs}) do
   %{data: (for blog <- blogs, do: show(blog))}
  end

  def show(blog) do
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
