defmodule Blog.Model.Topic do
  use Ecto.Schema
  import Ecto.Changeset

  schema "topics" do
    field :title, :string
    field :description, :string
    field :numberOfLikes, :integer, default: 0
    belongs_to :user, Blog.Model.User
    has_many :comments, Blog.Model.Comment
    has_many :likes, Blog.Model.Like

    timestamps()
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:title, :description])
    |> validate_required([:title, :description])
  end

end
