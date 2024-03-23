
#!/bin/bash

# Function to display network statistics
display_network_stats() {
    vnstat -l
}

# Main loop
while true; do
    clear
    echo "Network Usage Statistics:"
    display_network_stats
    sleep 1
done

