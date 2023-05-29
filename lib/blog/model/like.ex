defmodule Blog.Model.Like do
  use Ecto.Schema
  import Ecto.Changeset

  schema "likes" do
    belongs_to :topic, Blog.Model.Topic
    belongs_to :user, Blog.Model.User
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [])
  end

end
