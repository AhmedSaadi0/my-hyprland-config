#!/bin/bash

uptime_seconds=$(cut -d ' ' -f 1 /proc/uptime)
uptime_hours=$(echo "$uptime_seconds / 3600" | bc)
uptime_days=$(echo "$uptime_hours / 24" | bc)
remainder_hours=$(echo "$uptime_hours % 24" | bc)

if [[ $uptime_days -gt 0 ]]; then
    echo "$uptime_days ي : $remainder_hours س"
else
    echo "$uptime_hours"
fi
