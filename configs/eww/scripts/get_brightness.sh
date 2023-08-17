#!/bin/bash

# Specify the path to your backlight device (replace with the appropriate device name)
backlight_path="/sys/class/backlight/intel_backlight"

# Read the current brightness level and maximum brightness value
current_brightness=$(cat "$backlight_path"/brightness)
max_brightness=$(cat "$backlight_path"/max_brightness)

# Calculate the brightness percentage
brightness_percentage=$(( (current_brightness * 100) / max_brightness ))

# Print the result
echo "$brightness_percentage"
