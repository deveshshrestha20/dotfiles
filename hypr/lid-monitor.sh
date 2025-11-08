#!/bin/bash

LID_STATE=$(cat /proc/acpi/button/lid/LID0/state | awk '{print $2}')

if [ "$LID_STATE" = "closed" ]; then
    # disable laptop monitor
    hyprctl keyword monitor eDP-1,disable
    
    # move any workspaces on eDP-1 to HDMI-A-1
    for ws in $(hyprctl workspaces | grep eDP-1 | awk '{print $2}'); do
        hyprctl keyword workspace $ws,monitor,HDMI-A-1
    done

else
    # enable laptop monitor
    hyprctl keyword monitor eDP-1,enable
fi
