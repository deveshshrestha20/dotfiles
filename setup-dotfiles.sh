#!/bin/bash
# 🧩 setup-dotfiles.sh — Symlink dotfiles to ~/.config

# Define your dotfiles directory
DOTFILES="$HOME/dotfiles"

# List of config folders to link
CONFIGS=(
  "nvim"
  "hypr"
  "waybar"
  "wofi"
  "rofi"
  "kitty"
  "wlogout"
  "yazi"
  "swaylock"
  "wallpaper"
  "lobster"
  "pulse"
  "redshift"
)

# Make sure ~/.config exists
mkdir -p ~/.config

echo "🔗 Creating symlinks for your dotfiles..."
for folder in "${CONFIGS[@]}"; do
  # Remove existing folder if it exists
  if [ -d "$HOME/.config/$folder" ] || [ -L "$HOME/.config/$folder" ]; then
    rm -rf "$HOME/.config/$folder"
    echo "🗑️ Removed old $folder"
  fi

  # Create symlink
  ln -sf "$DOTFILES/$folder" "$HOME/.config/$folder"
  echo "✅ Linked $folder"
done

echo "🎉 All dotfiles linked successfully!"
