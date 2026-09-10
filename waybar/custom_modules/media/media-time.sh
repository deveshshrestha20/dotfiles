#!/usr/bin/env bash

mpris_status=$(playerctl status 2>/dev/null)
mpd_status=$(mpc status 2>/dev/null)

# Firefox / other MPRIS player
if [ "$mpris_status" = "Playing" ] || [ "$mpris_status" = "Paused" ]; then
  position=$(playerctl position 2>/dev/null)
  length=$(playerctl metadata --format '{{mpris:length}}' 2>/dev/null)

  if [ -n "$length" ] && [ "$length" != "0" ]; then
    position_sec=${position%.*}
    length_sec=$((length / 1000000))

    printf '%02d:%02d/%02d:%02d\n' \
      $((position_sec / 60)) \
      $((position_sec % 60)) \
      $((length_sec / 60)) \
      $((length_sec % 60))
  else
    # Firefox may not expose mpris:length
    position_sec=${position%.*}

    printf '%02d:%02d/--:--\n' \
      $((position_sec / 60)) \
      $((position_sec % 60))
  fi

# RMPC / MPD
elif printf '%s\n' "$mpd_status" | grep -qE '\[playing\]|\[paused\]'; then
  printf '%s\n' "$mpd_status" |
    sed -n '2s/.* \([0-9][0-9]*:[0-9][0-9]*\/[0-9][0-9]*:[0-9][0-9]*\).*/\1/p'
fi
