defmodule ReservationTest do
  use ExUnit.Case
  doctest Reservation

  test "greets the world" do
    assert Reservation.hello() == :world
  end
end
