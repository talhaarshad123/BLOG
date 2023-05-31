defmodule Blog.Topics do
  import Ecto
  alias Blog.Repo
  alias Blog.Model.Topic
  alias Blog.Users
  import Ecto.Query
  alias Blog.Model.Like

  def all_topics(page) do
    limit = 3
    query = from t in Topic,
    limit: ^limit,
    offset: (^page - 1) * ^limit,
    order_by: [desc: t.inserted_at],
    preload: [:likes]

    Repo.all(query)
  end
  def create_blog(blog, user_id) do
    Users.get_user_by_id(user_id)
    |> build_assoc(:topics)
    |> Topic.changeset(blog)
    |> Repo.insert()
  end

  def get_blog_by_id(topic_id) do
    Repo.get(Topic, topic_id)
  end

  def update_blog(currnet_blog ,title, description) do
    Ecto.Changeset.change(currnet_blog, title: title, description: description)
    |> Repo.update()
  end

  def delete_blog(blog_id) do
    Repo.get(Topic, blog_id)
    |> Repo.delete()
  end

  def get_customize_posts_with_likes_count() do
    query = from t in Topic,
    left_join: l in Like,
    on: t.id == l.topic_id,
    group_by: [t.id, l.topic_id],
    select: {t.id, t.title, count(l.id)}
    Repo.all(query)
  end

  def get_liked_posts(user_id) do
    query = from t in Topic,
    left_join: l in Like,
    on: t.id == l.topic_id,
    group_by: [t.id, l.topic_id],
    select: t.id,
    where: l.user_id == ^user_id

    Repo.all(query)
  end

  def get_user_posts(page, user_id) do
    limit = 3
    query = from t in Topic,
    limit: ^limit,
    offset: (^page - 1) * ^limit,
    order_by: [desc: t.inserted_at],
    preload: [:likes],
    where: t.user_id == ^user_id

    Repo.all(query)
  end
end
