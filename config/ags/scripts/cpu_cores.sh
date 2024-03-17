#!/bin/bash

# Get the CPU usage percentage for each core using 'mpstat'
cpu_usages=($(mpstat -P ALL 1 1 | awk '/^Average:/ && $12 != "all" {print 100 - $NF}'))

# Extract only the values
values="["
for ((i=0; i<${#cpu_usages[@]}; i++)); do
    values+=" ${cpu_usages[i]}"
    if [ $i -lt $(( ${#cpu_usages[@]} - 1 )) ]; then
        values+=","
    fi
done
values+=" ]"

# Print the JSON array of values
echo "$values"
