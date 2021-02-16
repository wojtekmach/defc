defmodule Cmark do
  use C, compile: "-I/opt/local/include -L/opt/local/lib -lcmark"

  defc(:global_parse, 1, ~S"""
  static ERL_NIF_TERM global_parse(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
  {
    ErlNifBinary markdown_bin;
    int cmark_options = CMARK_OPT_DEFAULT;
    cmark_node   *doc;

    if (argc != 1) {
      return enif_make_badarg(env);
    }

    if (!enif_inspect_binary(env, argv[0], &markdown_bin)) {
      return enif_make_badarg(env);
    }

    global_doc = cmark_parse_document(
      (const char *)markdown_bin.data,
      markdown_bin.size,
      cmark_options
    );

    return enif_make_atom(env, "ok");
  }
  """)

  defc(:global_to_commonmark, 0, ~S"""
  static cmark_node* global_doc;

  static ERL_NIF_TERM global_to_commonmark(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
  {
    int options = 0;
    ErlNifBinary  output_binary;
    char *output;
    size_t output_len;

    output = cmark_render_commonmark(global_doc, options, 0);
    output_len = strlen(output);
    enif_alloc_binary(output_len, &output_binary);
    memcpy(output_binary.data, output, output_len);
    cmark_node_free(global_doc);
    return enif_make_binary(env, &output_binary);
  }
  """)

  @doc ~S"""
  Transforms markdown to html.

  ## Examples

      iex> Cmark.markdown_to_html("hello")
      "<p>hello</p>\n"

  """
  defc(:markdown_to_html, 1, ~S"""
  #include<cmark.h>
  #include<string.h>

  char *get_event_type_string(cmark_event_type ev_type) {
    switch (ev_type) {
      case CMARK_EVENT_NONE: return "none";
      case CMARK_EVENT_DONE: return "done";
      case CMARK_EVENT_ENTER: return "enter";
      case CMARK_EVENT_EXIT: return "exit";
    }
  }

  static ERL_NIF_TERM markdown_to_html(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
  {
    ErlNifBinary markdown_bin;
    ErlNifBinary html_bin;
    size_t html_len;
    char *html;
    int cmark_options = CMARK_OPT_DEFAULT;

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
