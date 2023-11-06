#!/bin/bash

CURRENT_WORKSPACE=$(hyprctl activeworkspace -j | jq '.id')

TARGET_WORKSPACE="1$CURRENT_WORKSPACE"

WINDOWS=$(hyprctl clients -j | jq --arg TARGET_WS "$TARGET_WORKSPACE" '.[] | select(.workspace.id == ($TARGET_WS | tonumber)) | .address')

for WINDOWS_ADDRESS in $WINDOWS; do
  WINDOWS_ADDRESS=$(echo $WINDOWS_ADDRESS | tr -d '"')
  hyprctl dispatch movetoworkspacesilent "$CURRENT_WORKSPACE","address:$WINDOWS_ADDRESS"
done
