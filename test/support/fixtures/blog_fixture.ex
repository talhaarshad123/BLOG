defmodule Blog.BlogFixture do
  # import Blog.UserFixture

  @doc """
  Generates a Blog
  """


  def blog_fixture(user, attrs \\ %{}) do
    {:ok, blog}
    = attrs
    |> Enum.into(%{
      title: "some title",
      description: "some descrip"
    })
    |> Blog.Topics.create_blog(user.id)

    blog
  end

end
