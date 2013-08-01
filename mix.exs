defmodule Fcf.Mixfile do
  use Mix.Project

  def project do
    [ app: :fcf,
      version: "0.0.2",
      elixir: "~> 0.10.0",
      deps: deps ]
  end

  # Configuration for the OTP application
  def application do
    [applications: [:throttlex]]
  end

  # Returns the list of dependencies in the format:
  # { :foobar, "0.1", git: "https://github.com/elixir-lang/foobar.git" }
  defp deps do
    [{:throttlex,"0.0.2",git: "git@github.com:jschoch/Throttlex.git" }]
  end
end
