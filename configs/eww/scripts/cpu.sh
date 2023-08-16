#!/bin/bash

# Get the CPU usage percentage using top command
cpu_usage=$(top -bn 1 | grep "Cpu(s)" | awk '{print $2 + $4}')
# cpu_usage=$(top -bn 1 | grep '%Cpu(s)' | awk '{print $2}' | cut -d'%' -f1)
# Get the top 10 processes using the most CPU
top_processes=$(ps -eo pid,%cpu,comm --sort=-%cpu | head -n 11 | tail -n +2)

# Create a JSON object
json_output="{"
json_output+="\"cpu_usage\": $cpu_usage,"
json_output+="\"top_processes\": ["

# Loop through the top processes and add them to the JSON array
first_line=true
while read -r line; do
  if [ "$first_line" = true ]; then
    first_line=false
  else
    json_output+=","
  fi
  pid=$(echo "$line" | awk '{print $1}')
  cpu=$(echo "$line" | awk '{print $2}')
  command=$(echo "$line" | awk '{print $3}')
  json_output+="{\"pid\": $pid, \"cpu\": $cpu, \"command\": \"$command\"}"
done <<< "$top_processes"

json_output+="]"
json_output+="}"

# Print the JSON object
echo "$json_output"
