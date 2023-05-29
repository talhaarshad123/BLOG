defmodule Blog.Model.Comment do
  use Ecto.Schema
  import Ecto.Changeset

  schema "comments" do
    field :content, :string
    belongs_to :topic, Blog.Model.Topic
    belongs_to :user, Blog.Model.User

    timestamps()
  end

  def changeset(struct, attrs) do
    struct
    |> cast(attrs, [:content])
    |> validate_required([:content])
  end

end
