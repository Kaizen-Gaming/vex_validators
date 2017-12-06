defmodule VexValidators.Mixfile do
  use Mix.Project

  def project do
    [
      app: :vex_validators,
      version: "0.1.0",
      elixir: "~> 1.5",
      start_permanent: Mix.env == :prod,
      deps: deps()
    ]
  end

  def application do
    [
      extra_applications: []
    ]
  end

  defp deps do
    [
      {:vex, "~> 0.6"},
      {:ex_doc, "~> 0.18", only: :dev, runtime: false},
    ]
  end
end
