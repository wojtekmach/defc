defmodule CmarkTest do
  use ExUnit.Case, async: true
  doctest Cmark

  test "it works" do
    assert Cmark.markdown_to_html("hello") == "<p>hello</p>\n"
  end
end
