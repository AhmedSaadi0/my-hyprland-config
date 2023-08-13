#!/bin/bash

current_position=$(playerctl position)
total_duration=$(playerctl metadata mpris:length)
position_percentage=$(echo "scale=2; $current_position*1000000*100/$total_duration" | bc -l)
echo "$position_percentage"
