defmodule RemoteIpRewriterTest do
  use ExUnit.Case, async: true
  use Plug.Test

  @xff_header "x-forwarded-for"
  @x_real_ip "x-real-ip"

  defp remote_ip(conn, opts \\ []) do
    RemoteIpRewriter.call(conn, RemoteIpRewriter.init(opts))
  end

  describe "use default settings" do
    test "rewrites IPv4 address" do
      conn = conn(:get, "/")
             |> put_req_header(@xff_header, "158.15.47.12")
             |> remote_ip()
      assert conn.remote_ip == {158, 15, 47, 12}
    end

    test "rewrites IPv6 address" do
      conn = conn(:get, "/")
             |> put_req_header(@xff_header, "2001:0db8:ac10:fe01:0000:0000:0000:0000")
             |> remote_ip()
      assert conn.remote_ip == {8193, 3512, 44048, 65025, 0, 0, 0, 0}
    end

    test "does not rewrite if xff header is missing" do
      conn = conn(:get, "/")
             |> remote_ip()
      assert conn.remote_ip == {127, 0, 0, 1}
    end

    test "does not rewrite if xff header is malformed" do
      conn = conn(:get, "/")
             |> put_req_header(@xff_header, "malformed ip")
             |> remote_ip()
      assert conn.remote_ip == {127, 0, 0, 1}
    end

    test "does not rewrite non private network remote_ip address" do
      conn = conn(:get, "/")
             |> set_remote_ip({1, 2, 3, 4})
             |> put_req_header(@xff_header, "5.6.7.8")
             |> remote_ip()
      assert conn.remote_ip == {1, 2, 3, 4}
    end

    test "stops parsing on invalid ip" do
      conn = conn(:get, "/")
             |> put_req_header(@xff_header, "3.4.5.6, malformed ip")
             |> remote_ip()
      assert conn.remote_ip == {127, 0, 0, 1}
    end

    test "rewrites with rightmost non private network IPv4 address" do
      conn = conn(:get, "/")
             |> put_req_header(@xff_header, "3.4.5.6, 7.8.9.10, 127.0.0.1, 10.0.0.0, 10.255.255.255, 172.16.0.0, 172.31.255.255, 192.168.0.0, 192.168.255.255")
             |> remote_ip()
      assert conn.remote_ip == {7, 8, 9, 10}
    end

    test "rewrites with rightmost non private network IPv6 address" do
      conn = conn(:get, "/")
             |> put_req_header(@xff_header, "fe80:0000:0000:0000:0202:b3ff:fe1e:8329, 2001:0db8:ac10:fe01::, 0:0:0:0:0:0:0:1, ::1, fc00::, fc00:0000:0000:0000:0000:0000:0000:0000, fdff:ffff:ffff:ffff:ffff:ffff:ffff:ffff")
             |> remote_ip()
      assert conn.remote_ip == {8193, 3512, 44048, 65025, 0, 0, 0, 0}
    end
  end

  describe "use trusted_proxies" do
    test "skips private addresses and trusted proxies' addresses" do
      conn = conn(:get, "/")
             |> set_remote_ip({192, 168, 1, 4})
             |> put_req_header(@xff_header, "9.10.11.12, 5.6.7.8, 1.2.3.4, 1.1.1.1")
             |> remote_ip(trusted_proxies: ["1.2.3.0/24", "1.1.1.1/32"])
      assert conn.remote_ip == {5, 6, 7, 8}
    end
  end

  describe "use x-real-ip header" do
    test "returns rightmost non private ip" do
      conn = conn(:get, "/")
             |> put_req_header(@xff_header, "5.5.5.5, 6.6.6.6, 10.0.0.1")
             |> put_req_header(@x_real_ip, "7.7.7.7, 8.8.8.8, 10.0.0.1")
             |> remote_ip(header: "x-real-ip")
      assert conn.remote_ip == {8, 8, 8, 8}
    end

    test "returns remote_ip if header not present" do
      conn = conn(:get, "/")
             |> put_req_header(@xff_header, "5.5.5.5, 6.6.6.6, 10.0.0.1")
             |> remote_ip(header: "x-real-ip")
      assert conn.remote_ip == {127, 0, 0, 1}
    end

  end

  defp set_remote_ip(conn, value) do
    %{conn | remote_ip: value}
  end

end
