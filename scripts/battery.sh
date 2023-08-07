#!/bin/bash

# Get battery status
battery_info=$(acpi -b)
charging_status=$(echo "$battery_info" | grep -oP '(Charging|Discharging|Not charging)')
battery_percentage=$(echo "$battery_info" | grep -oP '\d+%' | tr -d '%')
show_time=15000

# Define sound file path
sound_file="/home/ahmed/.config/hypr/scripts/notification.ogg"

# Set XDG_RUNTIME_DIR if not already set
if [ -z "$XDG_RUNTIME_DIR" ]; then
    export XDG_RUNTIME_DIR="/run/user/$(id -u)"
fi

# Set DBUS_SESSION_BUS_ADDRESS if not already set
if [ -z "$DBUS_SESSION_BUS_ADDRESS" ]; then
    export DBUS_SESSION_BUS_ADDRESS="unix:path=$XDG_RUNTIME_DIR/bus"
fi

# Set icon and message based on battery level
if [[ $charging_status == "Discharging" && $battery_percentage -lt 40 ]]; then
    icon_name="~/.config/hypr/icons/battery-low.svg"
    message="نسبة البطارية أقل من 40%. حسب قاعدة 40-80 يفضل شحن جهازك المحمول الان."

    notify-send -i "$icon_name" -t "$show_time" "نسبة شحن البطارية ("$battery_percentage"%)" "$message"
    paplay $sound_file
elif [[ ($charging_status == "Charging" || $charging_status == "Not charging") && $battery_percentage -gt 80 ]]; then
    icon_name="~/.config/hypr/icons/battery-fully-charged.svg"
    message="نسبة البطارية أعلى من 80%. حسب قاعدة 40-80 يفضل فصل الشاحن الان"

    notify-send -i "$icon_name" -t "$show_time" "نسبة شحن البطارية ("$battery_percentage"%)" "$message"
    paplay $sound_file
fi
