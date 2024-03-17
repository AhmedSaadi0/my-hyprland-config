#!/bin/bash

# Get the CPU usage percentage using the 'top' command
cpu_usage=$(mpstat -P ALL 1 1 | awk 'END {print 100 - $NF}')

# Print the CPU usage percentage
echo "$cpu_usage"
