#!/bin/bash

# Check if the 'free' command is available
if ! command -v free &> /dev/null; then
    echo "The 'free' command is not available on this system."
    exit 1
fi

# Get total used and total available RAM in megabytes
total_used_ram=$(free -m | awk '/Mem:/ {print $3}')
total_available_ram=$(free -m | awk '/Mem:/ {print $2}')

# Calculate the used RAM as a percentage
used_ram_percentage=$((total_used_ram * 100 / total_available_ram))

echo "${used_ram_percentage}"
