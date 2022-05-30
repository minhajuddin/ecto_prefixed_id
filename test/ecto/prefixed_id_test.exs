defmodule Ecto.PrefixedIDTest do
  use ExUnit.Case
  doctest Ecto.PrefixedID

  test "greets the world" do
    assert Ecto.PrefixedID.hello() == :world
  end
end
