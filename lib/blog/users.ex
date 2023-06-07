defmodule Blog.Users do
  alias Blog.Model.User
  alias Blog.Repo
  # import Ecto

  def create_user(params) do
      %User{}
      |> User.changeset(params)
      |> Repo.insert()
  end



  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_id(user_id) do
    # IO.inspect("--------------USER--------------")
    Repo.get(User, user_id)
  end
  def updated_user(current_user, params) do
    current_user
    |> User.changeset(params)
    |> Repo.update()
    # Ecto.Changeset.change(current_user, fname: params["fname"], lname: params["lname"], email: params["email"], password: params["password"])
    # |> Repo.update()
  end

  def delete_user(user) do
    user
    |> Repo.delete()
  end

  def get_all_users() do
    Repo.all(User)
  end
end
