defmodule RemoteIpRewriter do
  import Plug.Conn, only: [get_req_header: 2]
  @behaviour Plug

  @xff_header "x-forwarded-for"

  def init(_opts) do
  end

  def call(conn, _opts) do
    conn
    |> get_req_header(@xff_header)
    |> rewrite_remote_ip(conn)
  end

  defp rewrite_remote_ip([], conn) do
    conn
  end

  defp rewrite_remote_ip([header | _], conn) do
    case ips_from(header) |> parse_addresses do
      ip when is_tuple(ip) ->
        %{conn | remote_ip: ip}
      nil ->
        conn
    end
  end

  # Header contains comma separated list of ips. Only the rightmost ip can be
  # trusted so the list of ips is reversed
  defp ips_from(header) do
    header
    |> String.split(",")
    |> Enum.reverse
  end

  defp parse_addresses([]), do: nil

  defp parse_addresses([address | rest]) do
    case address |> String.strip |> to_char_list |> :inet.parse_address do
      {:ok, ip} ->
        if private_network?(ip), do: parse_addresses(rest), else: ip
      _ ->
        nil
    end
  end

  defp private_network?({127, 0, 0, 1}), do: true
  defp private_network?({10, _, _, _}), do: true
  defp private_network?({172, octet, _, _}) when octet >= 16 and octet <= 31, do: true
  defp private_network?({192, 168, _, _}), do: true
  defp private_network?({0, 0, 0, 0, 0, 0, 0, 1}), do: true
  defp private_network?({digit, _, _, _, _, _, _, _}) when digit >= 0xFC00 and digit <= 0xFDFF, do: true
  defp private_network?(_), do: false

end
