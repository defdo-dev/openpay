defmodule Openpay.MixProject do
  @moduledoc false
  use Mix.Project

  @organization "paridincom"

  def project do
    [
      app: :openpay,
      version: "0.4.0",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      description: "This client allows interact with openpay.mx APIs.",
      package: package(),
      # exdocs
      name: "ADM Base",
      source_url: "https://github.com/paridin/openpay",
      homepage_url: "https://paridin.com",
      docs: [
        # The main page in the docs
        main: "Openpay",
        # logo: "logo.png",
        extras: ["README.md"]
      ],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.html": :test,
        "coveralls.json": :test,
        vcr: :test,
        "vcr.delete": :test,
        "vcr.check": :test,
        "vcr.show": :test
      ]
    ]
  end

  defp package do
    [
      organization: @organization,
      licenses: ["Apache-2.0"],
      links: %{}
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Openpay.Application, []}
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto, "~> 3.4"},
      {:money, "~> 1.9"},
      # * dynamic usage for this dependency
      {:httpoison, "~> 1.5"},
      {:plug_cowboy, "~> 2.3"},
      {:jason, "~> 1.2"},
      {:phoenix, "~> 1.6"},
      {:tzdata, "~> 1.1"},
      {:mix_test_watch, "~> 1.0", only: :dev, runtime: false},
      {:excoveralls, "~> 0.14", only: :test},
      {:credo, "~> 1.6", only: [:dev, :test], runtime: false},
      # * could be replaced to use mock
      {:exvcr, "~> 0.10", only: [:dev, :test]},
      {:mox, "~> 1.0", only: :test},
      {:ex_doc, "~> 0.26", only: :dev, runtime: false}
    ]
  end
end
