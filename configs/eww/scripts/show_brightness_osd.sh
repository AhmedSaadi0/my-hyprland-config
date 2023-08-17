#!/bin/bash

remaining_time=3

# Get the PID of the current script
current_pid=$$

# Get the PIDs of all processes named show_vol_osd.sh
osd_pids=$(pgrep -f "show_brightness_osd.sh")

# Filter out the current script's PID from the list
filtered_pids=""
for pid in $osd_pids; do
    if [ "$pid" != "$current_pid" ]; then
        filtered_pids="$filtered_pids $pid"
    fi
done

# Kill the remaining show_vol_osd.sh processes
if [ -n "$filtered_pids" ]; then
    kill $filtered_pids
fi

# Open brightness_osd
eww open brightness_osd
eww update brightnes_is_visible=true
# Wait for the remaining time
sleep $remaining_time

# Close brightness_osd
eww close brightness_osd
