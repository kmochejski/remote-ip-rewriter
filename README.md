# RemoteIpRewriter

An Elixir plug to rewrite the value of **remote_ip** key of [Plug.Conn](https://hexdocs.pm/plug/Plug.Conn.html) struct if an [X-Forwarded-For](https://en.wikipedia.org/wiki/X-Forwarded-For) header is found.
The addresses are processed from right to left to prevent ip-spoofing.
Any private network addresses are skipped as well as addresses defined in an optional `:trusted_proxies` setting.0

## Installation

  1. Add the plug to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:remote_ip_rewriter, "~> 0.1.0"}
      ]
    end
    ```

  2. If you are using [Phoenix Framework](http://www.phoenixframework.org/) then put the plug in your application's endpoint `lib\your_app\endpoint.ex`:

    ```elixir
    defmodule YourApp.Endpoint do
      ...
      plug RemoteIpRewriter
      ...
      plug YourApp.Router
    end
    ```
    
   3. There are two optional configuration settings to the plug:
   * `:header` - specifies what header contains remote ip. If not specified, then [X-Forwarded-For](https://en.wikipedia.org/wiki/X-Forwarded-For) header is parsed
   * `:trusted_proxies` - list of trusted proxies in CIDR notation

    ```elixir
    defmodule YourApp.Endpoint do
      ...
      plug RemoteIpRewriter, header: "x-real-ip", trusted_proxies: ["1.2.3.4/32", "5.6.7.8/24"]
      ...
      plug YourApp.Router
    end
    ```
