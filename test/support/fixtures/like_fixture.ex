defmodule Blog.LikeFixture do


  @doc """
  Generate a Like
  """

  def like_fixture(blog_id, user_id) do
    {:ok, like} = Blog.Likes.insert_like(blog_id, user_id)
    like
  end

end
