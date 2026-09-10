#!/usr/bin/env bash

firefox_status=$(playerctl -p firefox status 2>/dev/null)
mpd_status=$(mpc status 2>/dev/null)

if [ "$firefox_status" = "Playing" ]; then
    playerctl -p firefox metadata --format '{{title}} - {{artist}}'

elif printf '%s\n' "$mpd_status" | grep -q '\[playing\]'; then
    mpc current

elif [ "$firefox_status" = "Paused" ]; then
    playerctl -p firefox metadata --format '{{title}} - {{artist}}'

elif printf '%s\n' "$mpd_status" | grep -q '\[paused\]'; then
    mpc current
fi
