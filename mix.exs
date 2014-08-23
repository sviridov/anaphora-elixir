defmodule Anaphora.Mixfile do
  use Mix.Project

  def project do
    [app: :anaphorex,
     version: "0.0.1",
     elixir: "~> 0.15.1",
     deps: deps,
     package: package,
     description: description]
  end

  def application do
    []
  end

  defp deps do
    []
  end

  defp package do
    [contributors: ["Alexander Sviridov"],
     licenses: ["The MIT License"],
     links: %{"Github" => "https://github.com/sviridov/anaphorex"}]
  end
end
