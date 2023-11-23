#!/bin/bash

# Get the top 10 processes using the most RAM
top_processes=$(ps -eo pid,%mem,comm --sort=-%mem | head -n 11 | tail -n +2)

# Create an array for the top processes
processes_array=()

# Loop through the top processes and add them to the array
while read -r line; do
    pid=$(echo "$line" | awk '{print $1}')
    mem=$(echo "$line" | awk '{print $2}')
    command=$(echo "$line" | awk '{print $3}')
    processes_array+=("{\"pid\": \"$pid\", \"process\": \"$command\", \"%\": \"$mem\", \"user\": \"$USER\", \"command\": \"$command\"}")
done <<< "$top_processes"

# Join array elements with comma
processes_json=$(IFS=, ; echo "[${processes_array[*]}]")

# Print the JSON array
echo "$processes_json"
