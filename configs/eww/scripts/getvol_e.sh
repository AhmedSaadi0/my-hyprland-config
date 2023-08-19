#!/bin/bash

# Function to print the current volume and mute status
print_volume() {
    # Get volume level and mute status
    volume=$(pactl list sinks | grep 'Volume:' | head -n 1 | awk '{print $5}' | tr -d '%')
    is_muted=$(pactl list sinks | grep 'Mute:' | head -n 1 | awk '{print $2}')

    # Determine the icon based on volume and mute status
    if [ "$is_muted" == "yes" ]; then
        icon=""  # Muted symbol
    elif [ "$volume" -le 30 ]; then
        icon=""  # Low volume symbol
    else
        icon=""  # High volume symbol
    fi

    # Create JSON output
    json_output="{"
    json_output+="\"volume\": $volume,"
    json_output+="\"muted\": \"$is_muted\","
    json_output+="\"icon\": \"$icon\""
    json_output+="}"

    echo "$json_output"
}

# Initial volume print
print_volume

# Continuously monitor and print volume changes
pactl subscribe | while read -r event; do
    # Check if the event is related to volume change
    if [[ $event == *"change"* ]] && [[ $event == *"sink"* ]]; then
        # Print the updated volume
        print_volume
    fi
done
