defmodule Blog.UserFixture do
  @doc """
  Generate a user
  """

  def user_fixtures(attrs \\ %{}) do
    {:ok, user} =
      attrs
      |> Enum.into(%{
        "fname" => "fname",
        "lname" => "lname",
        "email" => "email@email",
        "password" => "password"
      })
      |> Blog.Users.create_user()
    user
  end
end
