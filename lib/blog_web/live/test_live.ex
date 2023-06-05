defmodule BlogWeb.TestLive do
  use Phoenix.LiveView
  alias Phoenix.PubSub
  alias Blog.Topics
  # alias Phoenix.Token
  # alias Blog.Likes

  def render(assigns) do
    ~L"""
      <h5>Topics</h5>
      <ul class="collection" id="test-id" phx-hook="TestTopics">
      <%= for topic <- @topics do %>
        <li class="collection-item">
          <%= topic.title %>
        </li>
      <% end %>
      </ul>
      <div class="fixed-action-btn">
      <a href="/my/new">
      <i class="material-icons">add</i>
      </a>
      </div>
    """
  end



  def mount(_, _, socket) do
    PubSub.subscribe(Blog.PubSub, "someTopic")
    topics = Topics.all_topics(1)
    {:ok, socket |> assign(topics: topics)}
  end

  # def mount(_, _, socket) do
  #   topics = Topics.all_topics(1)
  #   # PubSub.subscribe(Blog.PubSub, "likes")
  #   {:ok, socket |> assign(topics: topics, user_id: nil, authenticated: false, page: 1)}
  # end

  def handle_info(msg, socket) do
    IO.inspect("=====================")
    IO.inspect(msg)
    IO.inspect("++++++++++++++++++++++++")
    IO.inspect(socket)
    {:noreply, socket |> push_event("test-event", %{})}
  end

end
