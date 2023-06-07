defmodule BlogWeb.UserJSON do

  def user_response(%{user: user_params, msg: msg, token: token}) do
    %{
      data: data(user_params),
      token: token,
      details: msg
    }
  end

  def user_response(%{user: user_params, msg: msg}) do
    %{
      data: data(user_params),
      details: msg
    }
  end

  defp data(%Blog.Model.User{}=user) do
    %{
      fname: user.fname,
      lname: user.lname,
      email: user.email
    }
  end

  def error_handler(%{error: error_details}) do
    %{details: error_details}
  end

end
