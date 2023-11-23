defmodule SwiftExample do
  import Swift

  defswift("""
  @_cdecl("the_answer")
  func the_answer() -> Int {
      42
  }
  """)

  use C, compile: swift_flags()

  @doc """
  Hello from Swift!

  ## Examples

      iex> SwiftExample.hello()
      42

  """

  defc(:hello, 0, """
  extern int the_answer();

  static ERL_NIF_TERM hello_nif(ErlNifEnv* env, int argc, const ERL_NIF_TERM argv[])
  {
    return enif_make_int(env, the_answer());
  }
  """)
end
