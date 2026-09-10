#!/usr/bin/env bash

while true; do
  firefox_status=$(playerctl -p firefox status 2>/dev/null)
  mpd_status=$(mpc status 2>/dev/null)

  if [ "$firefox_status" = "Playing" ]; then
    playerctl -p firefox metadata \
      --format '{{title}} - {{artist}}' 2>/dev/null

  elif printf '%s\n' "$mpd_status" | grep -q '\[playing\]'; then
    mpc current 2>/dev/null

  elif [ "$firefox_status" = "Paused" ]; then
    playerctl -p firefox metadata \
      --format '{{title}} - {{artist}}' 2>/dev/null

  elif printf '%s\n' "$mpd_status" | grep -q '\[paused\]'; then
    mpc current 2>/dev/null

  else
    echo ""
  fi

  sleep 1
done
