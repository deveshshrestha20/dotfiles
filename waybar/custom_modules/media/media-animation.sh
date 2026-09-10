#!/usr/bin/env bash

animation_frames=("▂▄▆" "▄▂▆" "▄▆▂" "▆▄▂" "▆▂▄")

while :; do
  for frame in "${animation_frames[@]}"; do

    mpris_status=$(playerctl status 2>/dev/null)
    mpd_status=$(mpc status 2>/dev/null)

    if [ "$mpris_status" = "Playing" ] ||
      printf '%s\n' "$mpd_status" | grep -q '\[playing\]'; then

      echo "$frame"

    elif [ "$mpris_status" = "Paused" ] ||
      printf '%s\n' "$mpd_status" | grep -q '\[paused\]'; then

      echo ""

    else
      echo ""
    fi

    sleep 0.1
  done
done
