defmodule CmarkTest do
  use ExUnit.Case, async: true
  # doctest Cmark

  test "it works" do
    markdown = "  - foo\n  - bar\n"
    :ok = Cmark.global_parse(markdown)
    assert Cmark.global_to_commonmark() == markdown

    markdown = "  * foo\n  * bar"
    :ok = Cmark.global_parse(markdown)
    assert Cmark.global_to_commonmark() == "  - foo\n  - bar\n"
  end
end
