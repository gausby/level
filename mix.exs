defmodule Level.Mixfile do
  use Mix.Project

  def project do
    [app: :level,
     version: "1.0.0",
		 description: description,
		 package: package,
     elixir: "~> 1.0",
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  def application do
    [applications: [:logger, :eleveldb]]
  end

  defp deps do
    [{:eleveldb, github: "basho/eleveldb", branch: "develop"}]
  end

	defp description do
		"""
    Level implements various helper functions and data types for working with Googles Level data store.
    """
	end

	defp package do
    %{
      licenses: ["MIT"],
      contributors: ["Martin Gausby"],
      links: %{ "GitHub" => "https://github.com/gausby/level"},
      files: ~w(lib config mix.exs README* CHANGELOG*)
		}
  end
end
