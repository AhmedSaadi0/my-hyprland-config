#!/bin/bash

sensor_data=$(sensors -u)

get_sensor_temp() {
    label=$1
    temp=$(echo "$sensor_data" | awk -v label="$label" '
        /^'"$label"'/ {
            if (!/pch_cannonlake-virtual-0/) {
                getline; sub(/\+/, "", $2); print $2; exit
            }
        }
    ')
    echo "$temp"
}

echo "{
  \"wifi\": $(get_sensor_temp 'temp1'),
  \"nvme_total\": $(get_sensor_temp 'Composite'),
  \"nvme_sensor1\": $(get_sensor_temp 'Sensor 1:'),
  \"nvme_sensor2\": $(get_sensor_temp 'Sensor 2:'),
  \"cpu_total\": $(get_sensor_temp 'Package id 0:'),
  \"cpu_core0\": $(get_sensor_temp 'Core 0:'),
  \"cpu_core1\": $(get_sensor_temp 'Core 1:'),
  \"cpu_core2\": $(get_sensor_temp 'Core 2:'),
  \"cpu_core3\": $(get_sensor_temp 'Core 3:'),
  \"cpu_core4\": $(get_sensor_temp 'Core 4:'),
  \"cpu_core5\": $(get_sensor_temp 'Core 5:')
}"
