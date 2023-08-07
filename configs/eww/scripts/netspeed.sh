#!/bin/bash

# Get network interface name (replace with your interface)
interface="wlp0s20f3"

# Function to convert bytes to human-readable format
convert_to_human_readable() {
    local bytes="$1"
    
    if (( bytes < 1024 )); then
        echo "${bytes} B/s"
    elif (( bytes < 1048576 )); then
        echo "$(( bytes / 1024 )) KB/s"
    else
        echo "$(( bytes / 1048576 )) MB/s"
    fi
}

# Capture network speeds and output JSON
capture_speeds() {
    rx_before=$(cat "/sys/class/net/$interface/statistics/rx_bytes")
    tx_before=$(cat "/sys/class/net/$interface/statistics/tx_bytes")
    
    sleep 0.4
    
    rx_after=$(cat "/sys/class/net/$interface/statistics/rx_bytes")
    tx_after=$(cat "/sys/class/net/$interface/statistics/tx_bytes")
    
    # Calculate download and upload speeds
    download_speed=$((rx_after - rx_before))
    upload_speed=$((tx_after - tx_before))
    
    # Convert speeds to human-readable format
    download_formatted=$(convert_to_human_readable "$download_speed")
    upload_formatted=$(convert_to_human_readable "$upload_speed")
    
    json="{\"download\": \"$download_formatted\", \"upload\": \"$upload_formatted\"}"
    echo "$json"
}

# Capture and output speeds
capture_speeds