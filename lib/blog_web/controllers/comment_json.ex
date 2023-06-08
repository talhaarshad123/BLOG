defmodule BlogWeb.CommentJSON do


  def show(%{comment: comment, blog: blog}) do
    %{
      blog: %{
        id: blog.id,
        title: blog.title,
        description: blog.description,
        comment: show(comment)
      }
    }
  end

  def show(%{comment: comment}) do
    %{
      id: comment.id,
      content: comment.content
    }
  end


  def error_handler(%{error: error_details}) do
    %{details: error_details}
  end

end
