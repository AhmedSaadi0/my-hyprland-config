#!/usr/bin/env bash

# Script to download an MP3 with the best quality using yt-dlp

# Prompt the user to enter the video URL
echo "Enter the video URL:"
read video_url

# Check if yt-dlp is installed
if ! command -v yt-dlp &>/dev/null; then
    echo "Error: yt-dlp is not installed. Please install it first."
    exit 1
fi

# Download audio as MP3 with the best quality
echo "Downloading audio as MP3 with the best quality..."
yt-dlp -f bestaudio --extract-audio --audio-format mp3 --audio-quality 0 -o "%(title)s.%(ext)s" "$video_url"

# Notify the user of completion
echo "Download complete! The MP3 file has been saved in the current directory."
