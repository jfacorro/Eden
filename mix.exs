defmodule Eden.Mixfile do
  use Mix.Project

  def project do
    [app: :eden,
     version: "0.2.0",
     elixir: "~> 1.1",
     description: description,
     package: package,
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:timex, :array]]
  end

  defp deps do
    [{:array, "~> 1.0.1"},
     {:timex, "~> 0.19.5"},

     {:exreloader, github: "jfacorro/exreloader", tag: "master", only: :dev},
     {:ex_doc, "~> 0.7", only: :docs},
     {:earmark, ">= 0.0.0", only: :docs}]
  end

  defp description do
    """
    edn (extensible data notation) encoder/decoder implemented in Elixir.
    """
  end

  defp package do
    [files: ["lib", "priv", "mix.exs", "README*", "readme*", "LICENSE*", "license*"],
     maintainers: ["Juan Facorro"],
     licenses: ["Apache 2.0"],
     links: %{"GitHub" => "https://github.com/jfacorro/Eden/",
              "edn format" => "https://github.com/edn-format/edn"}]
  end
end
