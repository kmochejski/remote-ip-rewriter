# RemoteIpRewriter

An Elixir plug to rewrite the value of **remote_ip** key of [Plug.Conn](https://hexdocs.pm/plug/Plug.Conn.html) struct if an [X-Forwarded-For](https://en.wikipedia.org/wiki/X-Forwarded-For) header is found.
The addresses are processed from right to left to prevent ip-spoofing.
Any private network addresses are skipped.

## Installation

  1. Add the plug to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [
        {:remote_ip_rewriter, "~> 0.0.1"}
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
