#!/bin/bash

# Get battery percentage
battery_percentage=$(cat /sys/class/power_supply/BAT0/capacity)

# Get battery status (Charging/Discharging)
battery_status=$(cat /sys/class/power_supply/BAT0/status)

# Define battery icons based on percentage ranges
if [ "$battery_status" == "Charging" ]; then
    battery_icon=""
elif ((battery_percentage >= 80)); then
    battery_icon=""
elif ((battery_percentage >= 70)); then
    battery_icon=""
elif ((battery_percentage >= 65)); then
    battery_icon=""
elif ((battery_percentage >= 40)); then
    battery_icon=""
else
    battery_icon=""
fi

# Build JSON object
json="{\"icon\": \"$battery_icon\", \"percentage\": \"$battery_percentage\", \"status\": \"$battery_status\"}"

# Print JSON object
echo "$json"
