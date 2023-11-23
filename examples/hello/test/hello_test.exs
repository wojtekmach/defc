defmodule HelloTest do
  use ExUnit.Case, async: true

  test "hello/0" do
    assert Hello.hello() == ~c"Hello world!"
  end

  test "add/2" do
    assert Hello.add(1, 2) == 3
  end
end
