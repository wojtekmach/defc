defmodule CurlTest do
  use ExUnit.Case, async: true

  test "curl" do
    IO.inspect(Curl.test())
  end
end
