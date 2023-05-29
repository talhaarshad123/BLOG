defmodule BlogWeb.TestLive do
  use Phoenix.LiveView


  def render(assigns) do
    ~L"""
    <h1>counter: <%= @counter %> </h1>
    </div>
    """
  end

  def mount(_, _session, socket) do
    # IO.inspect("------------------")
    # IO.inspect(session)
    {:ok, assign(socket, counter: 0)}
  end
  # def handle_event("update", %{"key" => "ArrowDown"}, socket) do
  #   {:ok, assign(socket, counter: socket.assigns.counter - 1)}
  # end
  # def handle_event("update", _, socket) do
  #   {:ok, socket}
  # end
end
