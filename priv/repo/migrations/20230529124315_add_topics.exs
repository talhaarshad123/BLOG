defmodule Blog.Repo.Migrations.AddTopics do
  use Ecto.Migration

  def change do
    create table(:topics) do
      add :title, :string
      add :description, :string
      add :numberOfLikes, :integer
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end
  end
end
