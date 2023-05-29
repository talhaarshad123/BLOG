defmodule Blog.Repo.Migrations.AddLike do
  use Ecto.Migration

  def change do
    create table(:likes) do
      add :topic_id, references(:topics, on_delete: :delete_all)
      add :user_id, references(:users, on_delete: :delete_all)
    end
  end
end
