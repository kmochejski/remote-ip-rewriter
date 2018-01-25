# RemoteIpRewriter

An Elixir plug to rewrite the value of **remote_ip** key of [Plug.Conn](https://hexdocs.pm/plug/Plug.Conn.html) struct if an [X-Forwarded-For](https://en.wikipedia.org/wiki/X-Forwarded-For) header (*or any other predefined*) is found.
The addresses are processed from right to left to prevent ip-spoofing.
Any private network addresses are skipped as well as addresses defined in an optional `:trusted_proxies` setting.

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
    
   3. There are three optional configuration settings to the plug:
   * `:header` - specifies the header name to be parsed. If not specified, then [X-Forwarded-For](https://en.wikipedia.org/wiki/X-Forwarded-For) header is parsed.
   * `:trusted_proxies` - list of trusted proxies in CIDR notation.
   * `:trust_remote_ip` - trust remote ip - use this option if your server is directly behind a trusted proxy (i.e. load balancer). By default remote ip **is not trusted**.

    ```elixir
    defmodule YourApp.Endpoint do
      ...
      plug RemoteIpRewriter, header: "x-real-ip", trusted_proxies: ["1.2.3.4/32", "5.6.7.8/24"], trust_remote_ip: true
      ...
      plug YourApp.Router
    end
    ```
