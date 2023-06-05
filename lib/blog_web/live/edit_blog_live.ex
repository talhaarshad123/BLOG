defmodule BlogWeb.EditBlogLive do
  use Phoenix.LiveView
  alias Phoenix.Token
  alias Blog.Topics


  def render(assigns) do
    ~L"""
      <div class="row">
      <form class="col s6" phx-submit="save" style="display: inline-block; margin-left: 25%;
      margin-right:25%; width: 50%; margin-top: 8%">
      <div class="row">
      <div class="input-field col s6">
        <input type="text" placeholder="Enter Title" name="title" value= "<%= @topic.title %>" required >
        <%= if @titleRequired do %>
          <span>!enter valid email</span>
        <% end %>
      </div>
      <div class="input-field col s6">
        <input type="text"  placeholder="Enter Description" name="description" value= "<%= @topic.description %>" required >
        <%= if @descripRequired do %>
          <span>Field is required</span>
        <% end %>
      </div>
      </div>
      <button class="btn waves-effect waves-light" type="submit" name="action" >Save</button>
      </form>
      </div>
    """
  end

  def mount(%{"edit" => topic_id}, %{"auth_token" => auth_token}, socket) do
    topic_id = String.to_integer(topic_id)
    {:ok, user_id} = Token.verify(BlogWeb.Endpoint, "somekey", auth_token)
    if is_owner?(topic_id, user_id) do
      topic = Topics.get_blog_by_id(topic_id)
      {:ok, socket |> assign(topic: topic, titleRequired: false, descripRequired: false)}
    else
      {:ok, socket |> put_flash(:error, "Not allowed.") |> redirect(to: "/")}
    end
  end

  def handle_event("save", %{"description" => description, "title" => title}, socket) do
    topic = socket.assigns.topic
    case Topics.update_blog(topic, %{title: title, description: description}) do
      {:ok, _changeset} -> {:noreply, socket |> put_flash(:info, "Blog updated") |> redirect(to: "/")}
      {:error, _changeset} -> {:noreply, socket |> put_flash(:error, "Oops something went wrong"), redirect(to: "/")}
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
