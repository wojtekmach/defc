Mix.install([
  {:c, path: "#{__DIR__}/.."}
])

defmodule Hello do
  use C

  ~C"""
  static ERL_NIF_TERM hello(ErlNifEnv* env)
  {
    return enif_make_string(env, "Hello world!", ERL_NIF_LATIN1);
  }

  static ERL_NIF_TERM add(ErlNifEnv* env, ERL_NIF_TERM arg0, ERL_NIF_TERM arg1)
  {
    int a, b;

    if (!enif_get_int(env, arg0, &a) || !enif_get_int(env, arg1, &b)) {
        return enif_make_badarg(env);
    }

    return enif_make_int(env, a + b);
  }
  """
end

IO.inspect(Hello.hello())
IO.inspect(Hello.add(1, 2))
