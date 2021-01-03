defmodule HelloTest do
  use ExUnit.Case, async: true

  test "hello/0" do
    assert Hello.hello() == 'Hello world!'
  end
end
