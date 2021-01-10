defmodule Cmark do
  use C, compile: "-I/opt/local/include -L/opt/local/lib -lcmark"

  @doc ~S"""
  Transforms markdown to html.

  ## Examples

      iex> Cmark.markdown_to_html("hello")
      "<p>hello</p>\n"

  """
  defc(:markdown_to_html, 1, ~S"""
  #include<cmark.h>
  #include<string.h>

  static ERL_NIF_TERM markdown_to_html(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
  {
    ErlNifBinary markdown_bin;
    ErlNifBinary html_bin;
    size_t html_len;
    char *html;
    int cmark_options = 0;

    if (argc != 1) {
      return enif_make_badarg(env);
    }

    if (!enif_inspect_binary(env, argv[0], &markdown_bin)) {
      return enif_make_badarg(env);
    }

    html = cmark_markdown_to_html((const char *) markdown_bin.data, markdown_bin.size, cmark_options);
    html_len = strlen(html);
    enif_alloc_binary(html_len, &html_bin);
    memcpy(html_bin.data, html, html_len);

    enif_release_binary(&markdown_bin);
    free(html);
    return enif_make_binary(env, &html_bin);
  }
  """)
end
