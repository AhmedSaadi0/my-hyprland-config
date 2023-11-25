#!/bin/bash

# Get the number of CPU cores
num_cores=$(nproc)

# Get the top 10 processes using the most CPU
top_processes=$(top -bn1 | awk 'NR > 7 {print $1,$9,$12}' | head -n 10)

# Create an array for the top processes
processes_array=()

# Loop through the top processes and add them to the array
first_line=true
while read -r line; do
  if [ "$first_line" = true ]; then
    first_line=false
  else
    processes_array+=(",")
  fi
  pid=$(echo "$line" | awk '{print $1}')
  cpu=$(echo "$line" | awk '{print $2}')
  # Normalize CPU usage by dividing by the number of CPU cores
  normalized_cpu=$(echo "scale=2; $cpu / $num_cores" | bc)
  command=$(echo "$line" | awk '{print $3}')
  processes_array+=("{\"pid\": \"$pid\", \"process\": \"$command\", \"%\": \"$normalized_cpu\"}")
done <<< "$top_processes"

# Print the JSON array
echo "[${processes_array[@]}]"
