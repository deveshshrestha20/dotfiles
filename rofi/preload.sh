#!/bin/bash
# Force image cache by showing rofi briefly
rofi -show drun -no-show-icons 2>/dev/null &
ROFI_PID=$!
sleep 0.15
kill $ROFI_PID 2>/dev/null
