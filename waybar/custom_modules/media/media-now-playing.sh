#!/usr/bin/env bash

if playerctl status 2>/dev/null | grep -q 'Playing'; then
  zscroll -l 20 \
    --delay 0.3 \
    --update-check true \
    "playerctl metadata --format '{{title}} - {{artist}}'" 2>/dev/null

elif mpc status 2>/dev/null | grep -q '\[playing\]'; then
  zscroll -l 20 \
    --delay 0.3 \
    --update-check true \
    "mpc current" 2>/dev/null
fi
