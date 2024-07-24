#!/usr/bin/env bash

sensor_data=$(sensors -u)

get_sensor_temp() {
    section=$1
    label=$2
    temp=$(echo "$sensor_data" | awk -v section="$section" -v label="$label" '
        BEGIN { in_section=0 }
        $0 ~ section {
            in_section=1
        }
        in_section && $1 ~ label {
            print $2
            exit
        }
        /^[[:space:]]*$/ {
            in_section=0
        }
    ')
    if [ -z "$temp" ]; then
        echo "null"
    else
        echo "$temp"
    fi
}


echo "iwlwifi_1-virtual-0 section:" >&2
echo "$sensor_data" | awk '/iwlwifi_1-virtual-0/,/^[[:space:]]*$/' >&2
echo "nvme-pci-0300 section:" >&2
echo "$sensor_data" | awk '/nvme-pci-0300/,/^[[:space:]]*$/' >&2
echo "coretemp-isa-0000 section:" >&2
echo "$sensor_data" | awk '/coretemp-isa-0000/,/^[[:space:]]*$/' >&2


echo "{
  \"wifi\": $(get_sensor_temp 'iwlwifi_1-virtual-0' 'temp1_input:'),
  \"nvme_total\": $(get_sensor_temp 'nvme-pci-0300' 'temp1_input:'),
  \"nvme_sensor1\": $(get_sensor_temp 'nvme-pci-0300' 'temp2_input:'),
  \"cpu_total\": $(get_sensor_temp 'coretemp-isa-0000' 'temp1_input:'),
  \"cpu_core0\": $(get_sensor_temp 'coretemp-isa-0000' 'temp2_input:'),
  \"cpu_core1\": $(get_sensor_temp 'coretemp-isa-0000' 'temp3_input:'),
  \"cpu_core2\": $(get_sensor_temp 'coretemp-isa-0000' 'temp4_input:'),
  \"cpu_core3\": $(get_sensor_temp 'coretemp-isa-0000' 'temp5_input:')
}"