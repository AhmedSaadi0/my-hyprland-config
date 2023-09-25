#!/bin/bash

# Check if lm-sensors is installed
if ! command -v sensors &> /dev/null; then
    echo "lm-sensors is not installed. Please install it first."
    exit 1
fi

# Use sensors command to get temperature information
temperature=$(sensors | grep 'Core\|Sensor' | awk '{print $3}')

# Print the temperature
echo "$temperature"
