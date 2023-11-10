#!/bin/bash

CURRENT_WORKSPACE=$(hyprctl activeworkspace -j | jq '.id')

TARGET_WORKSPACE="1$CURRENT_WORKSPACE"

ACTIVE_WINDOW=$(hyprctl activewindow -j | jq .address)

hyprctl dispatch movetoworkspacesilent $TARGET_WORKSPACE
