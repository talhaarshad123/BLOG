defmodule Blog.CommentFixture do


  @doc """
  Generate a comment
  """

  def comment_fixture(blog, user_id) do
    comment_content = %{
      content: "some comment content"
    }
    {:ok, comment} = blog
      |> Blog.Comments.insert_comment(comment_content, user_id)

    comment
  end


end
