#!/usr/bin/env bash

# Check if the input argument is provided
if [ -z "$1" ]; then
	echo "Usage: $0 <folder_path>"
	exit 1
fi

# Get the folder path from the first argument
folder_path=$1

# Check if the folder exists
if [ ! -d "$folder_path" ]; then
	echo "The specified folder does not exist."
	exit 1
fi

# Loop through all files in the folder
for image_file in "$folder_path"/*; do
	# Get the MIME type of the file
	mime_type=$(file --mime-type -b "$image_file")

	# Check if the file is an image
	if [[ $mime_type == image/* ]]; then
		# Get the base name of the file (without extension)
		base_name=$(basename "$image_file")
		base_name_no_ext="${base_name%.*}"

		# Convert the image file to .png
		magick "$image_file" "$folder_path/$base_name_no_ext.png"

		# Check if the conversion was successful
		if [ $? -eq 0 ]; then
			echo "Converted: $image_file to $folder_path/$base_name_no_ext.png"
		else
			echo "Failed to convert: $image_file"
		fi
	else
		echo "Skipping non-image file: $image_file"
	fi
done
