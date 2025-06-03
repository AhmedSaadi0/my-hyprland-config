#!/usr/bin/env bash

# Check if the correct number of arguments is provided
if [ $# -ne 1 ]; then
	echo "Usage: $0 <command>"
	echo "Commands: play, stop, next, play-pause, pause, previous"
	exit 1
fi

# Extract the command argument
command=$1

# Check if the command is one of the supported commands
case $command in
play | stop | next | play-pause | pause | previous) ;;
*)
	echo "Invalid command: $command"
	echo "Supported commands: play, stop, next, play-pause, pause, previous"
	exit 1
	;;
esac

# Perform the action using playerctl
playerctl -p strawberry "$command"
