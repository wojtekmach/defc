defmodule Sqlite3Test do
  use ExUnit.Case
  doctest Sqlite3

  test "it works" do
    assert Sqlite3.test() == :ok
  end
end
