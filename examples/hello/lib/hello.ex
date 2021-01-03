defmodule Hello do
  use C

  defc(:hello, 0, """
  static ERL_NIF_TERM hello(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
  {
    return enif_make_string(env, "Hello world!", ERL_NIF_LATIN1);
  }
  """)
end
