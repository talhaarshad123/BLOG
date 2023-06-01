defmodule BlogWeb.TestLive do
  use Phoenix.LiveView


  def render(assigns) do
    ~L"""
    <ul id="some-id" phx-hook="HookName">
    </ul>
    <button phx-click="inc">INC</button>
    """
  end

  def mount(_, _session, socket) do
    {:ok, socket
    |> push_event("some-event", %{
      content: "some-content-on-mount"
    })}
  end

  def handle_event("inc", _, socket) do
    {:noreply, socket
    |> push_event("some-event", %{
      content: "some-content-on-mount"
    })}
  end

end
