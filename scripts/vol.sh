#!/bin/bash

# Get the current volume level using amixer
volume=$(amixer get Master | grep -oE '[0-9]+%' | head -n 1)

# Check if the notification window is already open
if pidof -x "$(basename $0)" > /dev/null; then
    # If it's open, update the notification with the new volume level
    zenity --notification --text="Current volume level: $volume"
else
    # If it's not open, show the notification
    (zenity --notification --text="Current volume level: $volume" &) >/dev/null 2>&1
fi
