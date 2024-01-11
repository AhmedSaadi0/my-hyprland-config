#!/bin/bash

# Function to get temperature from specific sensors
get_sensor_temp() {
    label=$1
    temp=$(sensors -u | awk -v label="$label" '
        /^'"$label"'/ {
            if (!/pch_cannonlake-virtual-0/) {
                getline; sub(/\+/, "", $2); print $2; exit
            }
        }
    ')
    echo "$temp"
}

# Print temperatures in JSON format
echo "{
  \"temp1\": $(get_sensor_temp 'temp1'),
  \"Composite\": $(get_sensor_temp 'Composite'),
  \"Sensor1\": $(get_sensor_temp 'Sensor 1:'),
  \"Sensor2\": $(get_sensor_temp 'Sensor 2:'),
  \"Package_id_0\": $(get_sensor_temp 'Package id 0:'),
  \"Core0\": $(get_sensor_temp 'Core 0:'),
  \"Core1\": $(get_sensor_temp 'Core 1:'),
  \"Core2\": $(get_sensor_temp 'Core 2:'),
  \"Core3\": $(get_sensor_temp 'Core 3:'),
  \"Core4\": $(get_sensor_temp 'Core 4:'),
  \"Core5\": $(get_sensor_temp 'Core 5:')
}"
