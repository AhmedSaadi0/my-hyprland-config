#!/bin/bash

start_time="2024-01-01 00:00:00"  # Replace with your desired start time
end_time="2024-01-31 23:59:59"    # Replace with your desired end time
interface="wlp0s20f3"                 # Replace with your wireless interface name

# Get the unique ESSIDs associated with the wireless interface
essids=$(sudo iwconfig "$interface" | grep "ESSID:" | awk -F '"' '{print $2}' | sort -u)

# Iterate through each ESSID and get the internet usage using vnstat
usage_json="["

for essid in $essids; do
    # Get the total used internet data within the specified time range
    usage=$(vnstat --json --start "$start_time" --end "$end_time" -i "$interface" | jq --arg essid "$essid" '.interfaces[].traffic[] | select(.id == $essid) | .total')

    # Check if usage data is available, otherwise assign a default value of null
    if [ "$usage" == "" ]; then
        usage="null"
    fi

    # Append the ESSID and the corresponding internet usage to the JSON array
    usage_json+="{\"ESSID\":\"$essid\", \"Usage\":$usage},"
done

# Remove the trailing comma and close the JSON array
usage_json=${usage_json%,}
usage_json+="]"

echo "$usage_json"