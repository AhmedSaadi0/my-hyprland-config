#!/bin/bash

folder=$1 # Get the folder path from the first argument

if [ -z "$folder" ]; then
    echo "Please provide the folder path as an argument."
    exit 1
fi

mapfile -d '' files < <(find "$folder" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.gif" \) -print0)

json="["
for file in "${files[@]}"; do
    json+="\"$file\","
done
json=${json%?} # Remove the trailing comma
json+="]"

echo "$json" | jq .
