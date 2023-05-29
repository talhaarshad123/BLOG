defmodule BlogWeb.DeleteBlogLive do
  use Phoenix.LiveView
  alias Phoenix.Token
  alias Blog.Topic

  def render(assigns) do
    ~L"""
    """
  end
  def mount(%{"blog_id" => topic_id}, %{"auth_token" => auth_token}, socket) do
    topic_id = String.to_integer(topic_id)
    case Token.verify(BlogWeb.Endpoint, "somekey", auth_token) do
      {:ok, user_id} ->
        if is_owner?(topic_id, user_id) do

          case Topic.delete_blog(topic_id) do
            {:ok, _} -> {:ok, socket |> put_flash(:info, "Blog Deleted.") |> redirect(to: "/")}
            {:error, _} -> {:ok, socket |> put_flash(:error, "Oops Something went wrong") |> redirect(to: "/")}
          end
        else
          {:ok, socket |> put_flash(:error, "Not allowed.") |> redirect(to: "/")}
        end
      {:error, _} -> {:ok, socket |> put_flash(:error, "Unauthroized.") |> redirect(to: "/")}
    end
  end

  def mount(_, _, socket) do
    {:ok, socket |> put_flash(:error, "Unauthroized") |> redirect(to: "/")}
  end

  def is_owner?(topic_id, user_id) do
    case Topic.get_blog_by_id(topic_id) do
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
