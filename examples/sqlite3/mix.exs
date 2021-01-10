defmodule Sqlite3.MixProject do
  use Mix.Project

  def project do
    [
      app: :sqlite3,
      version: "0.1.0",
      elixir: "~> 1.12-dev",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:c, path: "../.."}
    ]
  end
end
