{
  writeShellApplication,
  libnatpmp,
  curl,
  gawk,
}:
writeShellApplication {
  name = "portforward";

  runtimeInputs = [
    libnatpmp
    curl
    gawk
  ];

  text = ''
    GATEWAY_IP="10.2.0.1"
    QBIT_URL="http://192.168.100.2:8080"
    QBIT_USER="admin"
    QBIT_PASS="$(cat /run/secrets/qbittorrent-password)"

    COOKIE_FILE=$(mktemp)
    trap 'rm -f "$COOKIE_FILE"' EXIT

    echo "Starting Native NAT-PMP Sidecar (Shell)..."
    sleep 5

    get_port() {
      natpmpc -a 1 0 udp 60 -g "$GATEWAY_IP" >/dev/null
      output=$(natpmpc -a 1 0 tcp 60 -g "$GATEWAY_IP")

      port=$(echo "$output" | awk '/Mapped public port/ {print $4}')

      if [ -z "$port" ]; then
        echo "Error: Failed to acquire port." >&2
        echo "Debug output: $output" >&2
        return 1
      fi

      echo "$port"
    }

    update_qbit() {
      local port=$1

      login_resp=$(curl -s -i --max-time 10 -c "$COOKIE_FILE" \
        -d "username=$QBIT_USER" \
        -d "password=$QBIT_PASS" \
        "$QBIT_URL/api/v2/auth/login")

      if ! echo "$login_resp" | grep -qE "200 OK|204 OK"; then
         echo "Error: qBittorrent login failed." >&2
         return 1
      fi

      curl -s --fail --max-time 10 -b "$COOKIE_FILE" \
        --data-urlencode "json={\"listen_port\": $port}" \
        "$QBIT_URL/api/v2/app/setPreferences"

      echo "Success: qBittorrent updated to port $port"
    }

    while true; do
      current_port=$(get_port)

      if [ -n "$current_port" ]; then
        update_qbit "$current_port"
      fi

      sleep 45
    done
  '';
}
