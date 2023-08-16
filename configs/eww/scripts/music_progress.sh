#!/bin/bash

current_position=$(playerctl position)
total_duration=$(playerctl metadata mpris:length)
position_percentage=$(echo "scale=2; $current_position*1000000*100/$total_duration" | bc -l)
# echo "$position_percentage"

#!/bin/bash

# Get the currently playing song and singer using playerctl
current_song=$(playerctl metadata xesam:title)
current_artist=$(playerctl metadata xesam:artist)

# Truncate song and artist names to 20 characters
max_length=20
truncated_song=${current_song:0:$max_length}
truncated_artist=${current_artist:0:32}

# Create a JSON object
json_output="{"
json_output+="\"position_percentage\": \"$position_percentage\","
json_output+="\"currently_playing\": \"$truncated_song\","
json_output+="\"artist\": \"$truncated_artist\""
json_output+="}"

echo "$json_output"
