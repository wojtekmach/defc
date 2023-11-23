defmodule C do
  def __root__(env) do
    config = Mix.Project.config()

    if config[:app] do
      Mix.Project.compile_path()
    else
      # "Mix.install script"
      hash =
        [Path.expand(env.file), env.module]
        |> :erlang.term_to_binary()
        |> :erlang.md5()
        |> Base.encode16(case: :lower)

      path = Path.join([System.tmp_dir!(), "c-" <> hash, "_build"])
      File.mkdir_p!(path)
      path
    end
  end

  defmacro __using__(opts) do
    quote do
      @on_load :init_nifs
      @before_compile C
      @opts unquote(opts)
      Module.register_attribute(__MODULE__, :defs, accumulate: true)

      import C, only: [defc: 3]

      @doc false
      def init_nifs do
        path = Path.join([unquote(__root__(__CALLER__)), "..", "lib", "#{__MODULE__}"])
        :ok = :erlang.load_nif(path, 0)
      end
    end
  end

  defmacro defc(name, arity, body) do
    quote do
      @defs {unquote(name), unquote(arity), unquote(body)}

      def unquote(name)(unquote_splicing(Macro.generate_arguments(arity, nil))) do
        _ = [unquote_splicing(Macro.generate_arguments(arity, nil))]
        :erlang.nif_error("NIF library not loaded")
      end
    end
  end

  def __before_compile__(env) do
    defs = Module.get_attribute(env.module, :defs)
    opts = Module.get_attribute(env.module, :opts)

    c_src = Path.join([__root__(env), "..", "c_src", "#{env.module}.c"])
    File.mkdir_p!(Path.dirname(c_src))

    so = Path.join([__root__(env), "..", "lib", "#{env.module}.so"])
    File.mkdir_p!(Path.dirname(so))

    File.write!(c_src, """
    #include "erl_nif.h"

    #{Enum.map_join(defs, "\n", fn {_name, _arity, body} -> body end)}

    static ErlNifFunc nif_funcs[] =
    {
    #{Enum.map_join(defs, ", ", fn {name, arity, _} -> "{\"#{name}\", #{arity}, #{name}}" end)}
    };

    int c_nif_upgrade(ErlNifEnv* caller_env, void** priv_data, void** old_priv_data, ERL_NIF_TERM load_info)
    {
        return 0;
    }

    ERL_NIF_INIT(#{env.module}, nif_funcs, NULL, NULL, c_nif_upgrade, NULL)
    """)

    i = Path.join([:code.root_dir(), "usr", "include"])

    cc =
      case :os.type() do
        {:unix, :darwin} ->
          "gcc -bundle -flat_namespace -undefined dynamic_lookup"

        {:unix, :linux} ->
          "gcc -shared"
      end

    cmd = "#{cc} -o #{so} #{c_src} -I #{i} #{opts[:compile]}"
    0 = Mix.shell().cmd(cmd)
  end
end
