defmodule Blog.User do
  alias Blog.Model.User
  alias Blog.Repo

  def create_user(params) do
    case get_user_by_email(params["email"]) do
      nil ->
        %User{}
        |> User.changeset(params)
        |> Repo.insert()
      user ->  {:emailError, user}
    end
  end


  def get_user_by_email(email) do
    Repo.get_by(User, email: email)
  end

  def get_user_by_email_password(email, password) do
    Repo.get_by(User, email: email, password: password)
  end

  def get_user_by_id(user_id) do
    # IO.inspect("--------------USER--------------")
    Repo.get(User, user_id)
  end
end
