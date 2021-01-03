defmodule Swift do
  defmacro defswift(body) when is_binary(body) do
    swift_o =
      Path.join([Mix.Project.compile_path(), "..", "lib", "lib#{inspect(__CALLER__.module)}.a"])

    File.mkdir_p!(Path.dirname(swift_o))

    swift_src =
      Path.join([
        Mix.Project.compile_path(),
        "..",
        "swift_src",
        "#{inspect(__CALLER__.module)}.swift"
      ])

    File.mkdir_p!(Path.dirname(swift_src))
    File.write!(swift_src, body)
    cmd = "swiftc -static -emit-library #{swift_src} -o #{swift_o}"
    0 = Mix.shell().cmd(cmd)
  end

  defmacro swift_flags() do
    build_dir = Path.join(Mix.Project.compile_path(), "..")
    "-L `xcrun --show-sdk-path`/usr/lib/swift #{build_dir}/lib/lib#{inspect(__CALLER__.module)}.a"
  end
end
