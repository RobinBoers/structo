defmodule Structo.MixProject do
  use Mix.Project

  @documentation "https://hexdocs.pm/structo"
  @git_repository "https://git.dupunkto.org/~axcelott/structo"

  def project do
    [
      app: :structo,
      version: "0.2.1",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      source_url: @git_repository,
      homepage_url: @documentation,
      description: description(),
      package: package(),
      docs: docs()
    ]
  end

  def description do
    "JavaScript-style object constructors"
  end

  defp package do
    [
      licenses: ["Unlicense"],
      links: %{"Sources" => @git_repository}
    ]
  end

  def application do
    [extra_applications: [:logger]]
  end

  def deps do
    [
      {:ex_doc, "~> 0.31", only: :dev, runtime: false}
    ]
  end

  defp docs do
    [
      main: "Structo",
      api_reference: false,
      authors: ["Robijntje"],
      formatters: ["html"],
      before_closing_head_tag: fn _ ->
        docs_extra_html()
      end
    ]
  end

  defp docs_extra_html do
    """
    <style>
      #summary { display: none }
    </style
    """
  end
end
