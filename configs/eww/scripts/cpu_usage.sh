#!/bin/bash

# Get the top 10 processes using CPU and remove duplicates
top_processes=$(ps -eo pid,%cpu,user,comm --sort=-%cpu | head -n 11 | awk 'NR>1 {print "{\"pid\":\""$1"\",\"process\":\""$4"\",\"%\":\""$2"\",\"user\":\""$3"\"},"}' | uniq)

# Remove trailing comma and wrap the output in an array
json_output="[$(echo "$top_processes" | sed '$ s/.$//')]"

echo "$json_output"
