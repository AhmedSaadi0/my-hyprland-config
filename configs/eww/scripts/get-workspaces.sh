#!/bin/bash

spaces () {
    # WORKSPACE_WINDOWS=$(hyprctl workspaces -j | jq '[.[] | {("workspace_" + (.id|tostring) + "_id"): .id, ("workspace_" + (.id|tostring) + "_windows"): .windows}] | add')
    # echo "$WORKSPACE_WINDOWS"
    WORKSPACE_WINDOWS=$(hyprctl workspaces -j | jq 'map({key: .id | tostring, value: .windows | tostring}) | from_entries')
    json_data=""
    data=""
    # Example loop and data
    for i in {1..8}; do
        extracted_value=$(echo "$WORKSPACE_WINDOWS" | grep -o "\"$i\": *\"[^\"]*\"" | cut -d'"' -f4)
        if [ -z "$extracted_value" ]; then
            extracted_value=0
        fi
        data+="\"workspace_$i\": \"$extracted_value\","
    done
    # Construct the JSON object
    # json_data="{$data}"
    json_data="{${data%?}}"
    
    # Save JSON data to a file
    echo "$json_data"
}

spaces
socat -u UNIX-CONNECT:/tmp/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock - | while read -r line; do
    spaces
done

