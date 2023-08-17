#!/bin/bash

# Function to print the current volume
print_volume() {
    volume=$(pactl list sinks | grep 'Volume:' | head -n 1 | awk '{print $5}' | tr -d '%')
    echo "$volume"
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
