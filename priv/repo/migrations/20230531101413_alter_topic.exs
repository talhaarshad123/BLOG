defmodule Blog.Repo.Migrations.AlterTopic do
  use Ecto.Migration

  def change do
    alter table(:topics) do
      remove :numberOfLikes
    end
  end
end
