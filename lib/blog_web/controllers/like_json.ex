defmodule BlogWeb.LikeJSON do


  def show(%{like: like}) do
    %{
      id: like.id,
      user: like.user_id,
      blog: like.topic_id
    }
  end

  def error_handler(%{error: error_details}) do
    %{details: error_details}
  end


end
