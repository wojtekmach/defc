defmodule DefC.Formatter do
  @behaviour Mix.Tasks.Format

  @impl true
  def features(_opts) do
    [sigils: [:C]]
  end

  @impl true
  def format(contents, _opts) do
    if clang_format = System.find_executable("clang-format") do
      with_tmp_file(contents, fn path ->
        {out, 0} =
          System.cmd(clang_format, ["--style", "{BasedOnStyle: webkit, IndentWidth: 2}", path])

        out
      end)
    else
      contents
    end
  end

  defp with_tmp_file(contents, fun) do
    path = Path.join(System.tmp_dir!(), "defc_tmp_#{System.unique_integer([:positive])}")

    try do
      File.write!(path, contents)
      fun.(path)
    after
      File.rm(path)
    end
  end
end
