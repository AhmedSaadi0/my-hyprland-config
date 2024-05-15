
#!/bin/bash

# Get all network connections and their associated PIDs (requires root privileges)
sudo netstat -tulnp | awk 'NR > 2 {print $7}' | awk -F '/' '{print $1, $NF}' > /tmp/connections.txt

# Count occurrences of each PID (application)
pid_counts=$(awk '{print $2}' /tmp/connections.txt | sort | uniq -c | sort -nr)

# Print the sorted list of applications by usage
echo "Applications sorted by usage:"
echo "$pid_counts" | while read count pid; do
    app=$(ps -o comm= -p $pid)
    echo "[$count] $app"
done

