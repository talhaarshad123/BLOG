defmodule BlogWeb.TestNewLive do
  use Phoenix.LiveView
  alias Phoenix.PubSub
  alias Blog.Topics

  def render(assigns) do
    ~L"""
    <div class="row">
    <form class="col s6" phx-submit="save"style="display: inline-block; margin-left: 25%;
        margin-right:25%; width: 50%; margin-top: 8%">
      <div class="row">
        <div class="input-field col s6">
          <input placeholder="Enter Title" type="text" name="blog_details[title]" value= "<%= @blog_details["title"] %>" >
          <%= if @titleRequired do %>
            <span>Field is required</span>
          <% end %>
        </div>
        <div class="input-field col s6">
          <input type="text" placeholder="Enter description" name="blog_details[description]" value="<%= @blog_details["description"]%>" >
          <%= if @descripRequired do %>
            <span>Field is required</span>
          <% end %>
        </div>
      </div>
        <%= if @authenticated do %>
          <button class="btn waves-effect waves-light" type="submit" name="action" >Submit</button>
        <% end %>
    </form>
    </div>
    """
  end

  def mount(_, _, socket) do
    {:ok, socket
      |> assign(blog_details: %{"title" => "", "description" => ""}, titleRequired: false, descripRequired: false, authenticated: true)}
  end
  def handle_event("save", %{"blog_details" => blog_details}, socket) do
    Topics.create_blog(blog_details, 91)
    PubSub.broadcast(Blog.PubSub, "someTopic", {:blog_detail, blog_details})
    {:noreply, socket |> redirect(to: "/my")}
  end
end
