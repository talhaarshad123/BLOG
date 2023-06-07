defmodule BlogWeb.BlogJSON do
  alias Blog.Model.Topic

  def index(%{blogs: blogs}) do
    %{data: (for blog <- blogs, do: data(blog))}
  end

  def show(%{blog: blog}) do
    %{data: data(blog)}
  end

  def show(_) do
    %{details: "invalid ID"}
  end

  def blogComments(%{blog_comments: blog_comments}) do
    # IO.inspect(blog_comments)
    %{
      id: blog_comments.id,
      title: blog_comments.title,
      comments: (for comment <- blog_comments.comments, do: %{id: comment.id, title: comment.content})
    }
  end

  def edit(%{updated_blog: updated_blog}) do
    data(updated_blog)
  end

  def delete(%{deleted_blog: deleted_blog}) do
    data(deleted_blog)
  end

  def create(%{blog: blog}) do
    %{
      data: data(blog),
      details: "Blog Added"
    }
  end

  defp data(%Topic{} = blog) do
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
