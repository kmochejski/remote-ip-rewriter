defmodule RemoteIpRewriter.Mixfile do
  use Mix.Project

  @version "0.1.0"

  def project do
    [
      app: :remote_ip_rewriter,
      version: @version,
      elixir: "~> 1.2",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  def application do
    []
  end

  defp deps do
    [
      {:plug, "~> 1.1"},
      {:inet_cidr, "~> 1.0.0"}
    ]
  end

  defp description do
    """
    An Elixir plug to rewrite the value of remote_ip key of Plug.Conn struct if an X-Forwarded-For (or any other predefined) header is found.
    """
  end

  defp package do
    [
      files: ~w(lib mix.exs README.md LICENSE),
      maintainers: ["Krzysztof Mochejski"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/krzysztofmo/remote-ip-rewriter"}
    ]
  end

end
