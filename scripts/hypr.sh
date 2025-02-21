#!/usr/bin/env bash

# Path to the folder
folder_path="$HOME/.config/hypr/"

# Check if folder exists
if [ -d "$folder_path" ]; then
    # Change directory to the specified folder
    cd "$folder_path" || exit

    # Open NeoVim for the folder
    nvide &
    # konsole --hold -e fish -c "cd '$folder_path'; nvim; exec fish"
else
    echo "Folder $folder_path does not exist."
fi
