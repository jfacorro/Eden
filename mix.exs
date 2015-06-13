defmodule ExEdn.Mixfile do
  use Mix.Project

  def project do
    [app: :eden,
     version: "0.1.2",
     elixir: "~> 1.0",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger]]
  end

  defp deps do
    [{:array, "~> 1.0.1"},
     {:timex, "~> 0.13.4"},

     {:exreloader, github: "jfacorro/exreloader", tag: "master", only: :dev},
     {:ex_doc, "~> 0.7", only: :docs},
     {:earmark, ">= 0.0.0", only: :docs}]
  end

  defp description do
    """
    [edn](https://github.com/edn-format/edn) (extensible data notation)
    encoder/decoder implemented in Elixir.
    """
  end

  defp package do
    [files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     contributors: ["Juan Facorro"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/jfacorro/ExEdn/",
              "Docs" => "http://jfacorro.github.io/ExEdn/"}]
  end
end
