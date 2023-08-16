#!/bin/bash

# Get total and used memory using the free command
total_memory=$(free -m | awk 'NR==2 {print $2}')
used_memory=$(free -m | awk 'NR==2 {print $3}')

# Calculate the used memory percentage
used_percentage=$(( (used_memory * 100) / total_memory ))

echo $used_percentage
