#!/bin/sh

networkInterface="$1"

if [ -z "$networkInterface" ]; then
    echo "Usage: $0 <network-interface>"
    exit 1
fi

# Read TX and RX bytes
TX=$(cat /sys/class/net/"$networkInterface"/statistics/tx_bytes 2>/dev/null)
RX=$(cat /sys/class/net/"$networkInterface"/statistics/rx_bytes 2>/dev/null)

if [ -z "$TX" ] || [ -z "$RX" ]; then
    echo "Error: Interface '$networkInterface' not found or statistics unavailable."
    exit 1
fi

SSID="N/A"
SIGNAL="N/A"

# Check if interface is wireless by checking if it appears in nmcli device list as wifi
TYPE=$(nmcli -t -f DEVICE,TYPE device | grep "^$networkInterface:" | cut -d: -f2)

if [ "$TYPE" = "wifi" ]; then
    # Get active WiFi connection info
    # Output format: yes:<SSID>:<SIGNAL>
    WIFI_INFO=$(nmcli -t -f active,ssid,signal dev wifi | grep '^yes')

    if [ -n "$WIFI_INFO" ]; then
        SSID=$(echo "$WIFI_INFO" | cut -d: -f2)
        SIGNAL=$(echo "$WIFI_INFO" | cut -d: -f3)
    else
        SSID=
        SIGNAL=
    fi
fi

echo "${TX}::${RX}::${SSID}::${SIGNAL}"
