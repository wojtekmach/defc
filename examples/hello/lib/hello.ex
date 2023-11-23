defmodule Hello do
  use DefC

  ~C"""
  static ERL_NIF_TERM hello(ErlNifEnv* env)
  {
    return enif_make_string(env, "Hello world!", ERL_NIF_LATIN1);
  }
  """
end
