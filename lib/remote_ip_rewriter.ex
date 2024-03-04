defmodule RemoteIpRewriter do
  import Plug.Conn, only: [get_req_header: 2]
  @behaviour Plug

  @xff_header "x-forwarded-for"

  def init(opts) do
    header = Keyword.get(opts, :header, @xff_header)
    trusted_proxies = Keyword.get(opts, :trusted_proxies, []) |> Enum.map(&InetCidr.parse_cidr!/1)
    trust_remote_ip = Keyword.get(opts, :trust_remote_ip, false)
    {header, trusted_proxies, trust_remote_ip}
  end

  def call(conn, {header, trusted_proxies, trust_remote_ip}) do
    if trust_remote_ip || is_trusted?(conn.remote_ip, trusted_proxies)  do
      conn |> get_req_header(header) |> rewrite_remote_ip(conn, trusted_proxies)
    else
      conn
    end
  end

  defp rewrite_remote_ip([], conn, _) do
    conn
  end

  defp rewrite_remote_ip([header | _], conn, trusted_proxies) do
    case ips_from(header) |> parse_addresses(trusted_proxies) do
      remote_ip when is_tuple(remote_ip) ->
        %{conn | remote_ip: remote_ip}
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

  defp parse_addresses([], _), do: nil

  defp parse_addresses([address | rest], trusted_proxies) do
    case address |> String.trim() |> to_charlist() |> :inet.parse_address() do
      {:ok, remote_ip} ->
        if is_trusted?(remote_ip, trusted_proxies), do: parse_addresses(rest, trusted_proxies), else: remote_ip
      _ ->
        nil
    end
  end

  defp is_trusted?(remote_ip, trusted_proxies) do
    private_network?(remote_ip) || Enum.any?(trusted_proxies, &(InetCidr.contains?(&1, remote_ip)))
  end

  defp private_network?({127, 0, 0, 1}), do: true
  defp private_network?({10, _, _, _}), do: true
  defp private_network?({172, octet, _, _}) when octet >= 16 and octet <= 31, do: true
  defp private_network?({192, 168, _, _}), do: true
  defp private_network?({0, 0, 0, 0, 0, 0, 0, 1}), do: true
  defp private_network?({digit, _, _, _, _, _, _, _}) when digit >= 0xFC00 and digit <= 0xFDFF, do: true
  defp private_network?(_), do: false

end
