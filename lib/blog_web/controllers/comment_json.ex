defmodule BlogWeb.CommentJSON do



  def error_handler(%{error: error_details}) do
    %{details: error_details}
  end

  def new(%{comment: comment, blog: blog}) do
    %{
      blog: %{
        id: blog.id,
        title: blog.title,
        description: blog.description,
        comment: %{
          id: comment.id,
          content: comment.content
        }
      },
      details: "Comment Added"
    }
  end

end
