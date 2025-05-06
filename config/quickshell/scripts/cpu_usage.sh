#!/usr/bin/env bash

# Script to get CPU usage percentage over a short interval

# Define the interval in seconds
INTERVAL=1

# Function to get total and idle CPU times from /proc/stat
# The /proc/stat file contains CPU time statistics since boot.
# The first line 'cpu' sums up all cores.
# The fields on the 'cpu' line are (in USER_HZ):
# user, nice, system, idle, iowait, irq, softirq, steal, guest, guest_nice
# We need total time (sum of all fields) and idle time (5th field, index 4 in 0-based array, or $5 in awk).
get_cpu_stats() {
    # Use awk to process the 'cpu' line
    # Calculate total time = sum of all fields from the 2nd onwards ($1 is 'cpu')
    # Extract idle time = 5th field ($5)
    awk '/^cpu / {
        total=0;
        for(i=2; i<=NF; i++) total+=$i;
        # Field 5 is idle time according to man proc(5) for /proc/stat
        # Field 4 ($4) is nice time. Stick to the standard doc. # <-- CORRECTED LINE (removed the apostrophe)
        idle=$5;
        print total, idle;
    }' /proc/stat
}

# Read initial CPU stats
# The 'read' command can read multiple values into variables from a process substitution <(...)
read total_prev idle_prev < <(get_cpu_stats)

# Wait for the specified interval
sleep "$INTERVAL"

# Read new CPU stats
read total_curr idle_curr < <(get_cpu_stats)

# Calculate differences
total_delta=$((total_curr - total_prev))
idle_delta=$((idle_curr - idle_prev))

# Calculate CPU usage percentage
# Usage time = total time difference - idle time difference
# Percentage = (usage time / total time difference) * 100
# We use 'bc' for floating-point arithmetic and control precision

if [ "$total_delta" -eq 0 ]; then
    # Avoid division by zero if the system is completely stuck or interval is too short
    PERCENTAGE=0
else
    # Calculate percentage. Scale=0 gives integer output.
    PERCENTAGE=$(echo "scale=0; ((${total_delta} - ${idle_delta}) * 100) / ${total_delta}" | bc)
fi

# Output the percentage
echo "$PERCENTAGE"
