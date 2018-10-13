defmodule F2Test do
  use ExUnit.Case
  doctest F2

  test "greets the world" do
    assert F2.hello() == :world
  end
end
