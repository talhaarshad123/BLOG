defmodule BlogWeb.DeleteBlogLive do
  use Phoenix.LiveView
  alias Phoenix.Token
  alias Blog.Topics

  def render(assigns) do
    ~L"""
    """
  end
  def mount(%{"blog_id" => topic_id}, %{"auth_token" => auth_token}, socket) do
    topic_id = String.to_integer(topic_id)
    {:ok, user_id} = Token.verify(BlogWeb.Endpoint, "somekey", auth_token)
    if is_owner?(topic_id, user_id) do
      case Topics.delete_blog(topic_id) do
        {:ok, _} -> {:ok, socket |> put_flash(:info, "Blog Deleted.") |> redirect(to: "/")}
        {:error, _} -> {:ok, socket |> put_flash(:error, "Oops Something went wrong") |> redirect(to: "/")}
      end
    else
      {:ok, socket |> put_flash(:error, "Not allowed.") |> redirect(to: "/")}
    end
  end

  def is_owner?(topic_id, user_id) do
    case Topics.get_blog_by_id(topic_id) do
      nil -> false
      topic_changetset ->
        if topic_changetset.user_id == user_id do
          true
        else
          false
        end
    end
  end
end
