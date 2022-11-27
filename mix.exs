defmodule NervesSense.MixProject do
  use Mix.Project

  def project do
    [
      app: :nerves_sense,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      dialyzer: [
        ignore_warnings: "dialyzer.ignore.exs",
        list_unused_filters: true,
        plt_file: {:no_warn, plt_file_path()}
      ]
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
      {:circuits_i2c, "~> 1.1"},
      {:circuits_uart, "~> 1.5"},
      {:dialyxir, "~> 1.2", only: :dev, runtime: false}
    ]
  end

  # Path to the dialyzer .plt file.
  defp plt_file_path do
    [Mix.Project.build_path(), "plt", "dialyxir.plt"]
    |> Path.join()
    |> Path.expand()
  end
end
