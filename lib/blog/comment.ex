defmodule Blog.Comment do
  alias Blog.Repo
  alias Blog.Topic
  alias Blog.Model.Comment
  import Ecto

  def get_comments_by_blog(blog_id) do
    Topic.get_blog_by_id(blog_id)
    |> Repo.preload(comments: [:user])
  end

  def insert_comment(blog, content, user_id) do
    blog
    |> build_assoc(:comments, user_id: user_id)
    |> Comment.changeset(content)
    |> Repo.insert()
  end

  def get_comment_by_id(comment_id) do
    Repo.get(Comment, comment_id)
  end

  def update_comment(current_comment, content) do
    Ecto.Changeset.change(current_comment, content: content)
    |> Repo.update()
  end

  def delete_comment(comment_id) do
    Repo.get(Comment, comment_id)
    |> Repo.delete()
  end

  def get_comment_user(comment) do
    comment
    |> Repo.preload(:user)
  end
end
