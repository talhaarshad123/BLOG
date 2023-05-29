defmodule Blog.Like do
  alias Blog.Repo
  alias Blog.Topic
  import Ecto
  alias Blog.Model.Like

  def insert_like(blog_id, user_id) do
    Topic.get_blog_by_id(blog_id)
    |> build_assoc(:likes, user_id: user_id)
    |> Like.changeset()
    |> Repo.insert()
  end

  def get_like_by_blog_user(blog_id, user_id) do
    Repo.get_by(Like, topic_id: blog_id, user_id: user_id)
  end

  def delete_like(like_id) do
    Repo.get(Like, like_id)
    |> Repo.delete()
  end

end
