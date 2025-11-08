#!/usr/bin/env zsh

BROWSER="zen-browser"

# Zen Browser profile directory
ZEN_PROFILE="$HOME/.zen/6laop3je.Default (release)"
BOOKMARKS_DB="$ZEN_PROFILE/places.sqlite"

if [[ ! -f "$BOOKMARKS_DB" ]]; then
    notify-send "Zen Bookmarks" "Bookmarks database not found" -u critical
    exit 1
fi

#!/usr/bin/env zsh

BROWSER="zen-browser"

# Zen Browser profile directory
ZEN_PROFILE="$HOME/.zen/6laop3je.Default (release)"
BOOKMARKS_DB="$ZEN_PROFILE/places.sqlite"

if [[ ! -f "$BOOKMARKS_DB" ]]; then
    notify-send "Zen Bookmarks" "Bookmarks database not found" -u critical
    exit 1
fi

# Create a temporary copy to avoid database lock
TEMP_DB="/tmp/zen_bookmarks_$$.sqlite"
cp "$BOOKMARKS_DB" "$TEMP_DB"

# Extract bookmarks with favicon support
bookmarks=$(sqlite3 "$TEMP_DB" "
    SELECT DISTINCT moz_bookmarks.title, moz_places.url 
    FROM moz_bookmarks 
    JOIN moz_places ON moz_bookmarks.fk = moz_places.id 
    WHERE moz_bookmarks.title IS NOT NULL 
    AND moz_bookmarks.title != ''
    AND moz_places.url LIKE 'http%'
    ORDER BY moz_bookmarks.dateAdded DESC;
" 2>/dev/null | awk -F'|' '{
    title = $1
    url = $2
    
    # Add icons based on URL
    if (url ~ /youtube/) icon = " "
    else if (url ~ /github/) icon = " "
    else if (url ~ /reddit/) icon = " "
    else if (url ~ /twitter|x\.com/) icon = " "
    else if (url ~ /stackoverflow/) icon = " "
    else if (url ~ /chatgpt|openai/) icon = "🤖"
    else if (url ~ /google/) icon = " "
    else if (url ~ /monkeytype/) icon = " "
    else if (url ~ /netflix/) icon = " "
    else if (url ~ /spotify/) icon = " "
    else if (url ~ /anime|aniwatch/) icon = " "
    else icon = " "
    
    printf "%s %s\n    %s\n", icon, title, url
}')

# Clean up temporary database
rm -f "$TEMP_DB"

if [[ -z "$bookmarks" ]]; then
    notify-send "Zen Bookmarks" "No bookmarks found" -u normal
    exit 1
fi

# Add quit option with icon
menu_items="$bookmarks
 Quit"

# Show rofi menu with custom styling
choice=$(echo "$menu_items" | rofi -dmenu -i -l 15 -p '  Bookmarks' \
    -theme-str 'window { width: 50%; }' \
    -theme-str 'listview { lines: 15; }' \
    -markup-rows)

if [[ "$choice" == *"Quit"* ]] || [[ -z "$choice" ]]; then
    exit 0
else
    # Extract URL (second line after selection)
    url=$(echo "$choice" | grep -oP 'https?://[^\s]+' | head -1)
    if [[ -n "$url" ]]; then
        $BROWSER "$url" &
    fi
fi
