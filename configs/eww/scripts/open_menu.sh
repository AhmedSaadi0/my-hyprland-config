#!/bin/bash

# Run the command and capture its output
output=$(eww get left_menu_visible)

# Check if the output is true or false
if [[ "$output" == "true" ]]; then
    eww close left_menu
    eww update left_menu_visible=false
else
    eww open left_menu
    eww update left_menu_visible=true
fi
