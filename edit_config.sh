#!/bin/bash

CONFIG_DIR="$HOME/.config"
TERMINAL="kitty"
EDITOR="nvim"

# List of directories you want to include
INCLUDE_FOLDERS=(
  "rofi"
  "neofetch"
  "hypr-back"
  "waybar"
  "wlogout"
  "yazi"
  "nvim"
  "gitetch"
  "htop"
  "kitty"
  "kitty-back"
  "wlogout-back"
  "hypr"
)

# Gather all files from included folders
files=()
for folder in "${INCLUDE_FOLDERS[@]}"; do
  if [ -d "$CONFIG_DIR/$folder" ]; then
    while IFS= read -r f; do
      files+=("$f")
    done < <(find "$CONFIG_DIR/$folder" -type f)
  fi
done

# Show relative paths in Rofi menu
display_names=()
for f in "${files[@]}"; do
  display_names+=("${f#$CONFIG_DIR/}")
done

# Fuzzy search in Rofi
choice=$(printf '%s\n' "${display_names[@]}" | rofi -dmenu -i -p "Edit config:")

# Exit if nothing selected
[ -z "$choice" ] && exit 0

# Map selection back to full path
for i in "${!display_names[@]}"; do
  if [[ "${display_names[i]}" == "$choice" ]]; then
    full_path="${files[i]}"
    break
  fi
done

# Open in Kitty + Neovim
"$TERMINAL" "$EDITOR" "$full_path"
