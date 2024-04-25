#!/bin/bash

# Check if upower is installed
if ! command -v upower &> /dev/null; then
    echo "Error: 'upower' command not found. Please install it before running this script."
    exit 1
fi

# Function to get battery information
get_battery_info() {
    # Fetch battery information
    battery_info=$(upower -i $(upower -e | grep BAT))

    # Extract relevant information using grep and awk
    battery_state=$(echo "$battery_info" | grep "state:" | awk '{print $2}')
    warning_level=$(echo "$battery_info" | grep "warning-level:" | awk '{print $2}')
    voltage=$(echo "$battery_info" | grep "voltage:" | awk '{print $2}')
    charge_cycles=$(echo "$battery_info" | grep "charge-cycles:" | awk '{print $2}')
    time_to_empty=$(echo "$battery_info" | grep "time to empty:" | awk '{print $4}')
    percentage=$(echo "$battery_info" | grep "percentage:" | awk '{print $2}')
    capacity=$(echo "$battery_info" | grep "capacity:" | awk '{print $2}' | sed 's/%//')
    technology=$(echo "$battery_info" | grep "technology:" | awk '{print $2}')
    energy_rate=$(echo "$battery_info" | grep "energy-rate" | awk '{print $2}')
    energy_full_design=$(echo "$battery_info" | grep "energy-full-design" | awk '{print $2}')
    system_info=$(uname -r)
    
    # Format capacity to two decimal places
    capacity=$(printf "%.2f" "$capacity")

    # Create a JSON object
    json_output="{"
    json_output+="\"Battery_State\": \"$battery_state\","
    json_output+="\"Warning_Level\": \"$warning_level\","
    json_output+="\"Voltage\": \"$voltage\","
    json_output+="\"Charge_Cycles\": \"$charge_cycles\","
    json_output+="\"Time_To_Empty\": \"$time_to_empty\","
    json_output+="\"Kernel\": \"$system_info\","
    json_output+="\"Percentage\": \"$percentage\","
    json_output+="\"Capacity\": \"$capacity\","
    json_output+="\"Technology\": \"$technology\","
    json_output+="\"Energy_Rate\": \"$energy_rate\""
    json_output+="}"

    echo "$json_output"
}

# Print the JSON information
get_battery_info
