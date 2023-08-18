#!/bin/bash

is_visiable=$(eww get hardware_dashboard_visible)

if [[ "$is_visiable" == "true" ]]; then
    eww close hardware_dashboard
    eww update hardware_dashboard_visible=false
else
    eww open hardware_dashboard
    eww update hardware_dashboard_visible=true
fi
