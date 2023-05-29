defmodule Blog.Model.User do
  use Ecto.Schema
  import Ecto.Changeset
  # import Argon2


  schema "users" do
    field :fname, :string
    field :lname, :string
    field :email, :string
    field :password, :string
    has_many :topics, Blog.Model.Topic
    has_many :comments, Blog.Model.Comment
    has_many :likes, Blog.Model.Like

    timestamps()
  end

  def changeset(struct, attrs \\ %{}) do
    struct
    |> cast(attrs, [:fname, :lname, :email, :password])
    |> validate_required([:fname, :lname, :email, :password])
    |> unique_constraint([:email])
    # |> put_pass_hash()

  end

  # defp put_pass_hash(%Ecto.Changeset{valid?: true, changes: %{password: password}} = changeset) do
  #   change(changeset, add_hash(password))
  # end

  # defp put_pass_hash(changeset), do: changeset

end
