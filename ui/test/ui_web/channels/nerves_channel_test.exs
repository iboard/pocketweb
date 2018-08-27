defmodule UiWeb.NervesChannelTest do
  use UiWeb.ChannelCase

  alias UiWeb.NervesChannel

  setup do
    {:ok, _, socket} =
      socket("user_id", %{some: :assign})
      |> subscribe_and_join(NervesChannel, "nerves:lobby")

    {:ok, socket: socket}
  end

  test "broadcasts are pushed to the client", %{socket: socket} do
    broadcast_from! socket, "broadcast", %{"some" => "data"}
    assert_push "broadcast", %{"some" => "data"}
  end

end
