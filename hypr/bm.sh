#!/usr/bin/env zsh

BROWSER="zen-browser"

# Automatically find Zen Browser profile directory
ZEN_BASE="$HOME/.zen"
ZEN_PROFILE=$(find "$ZEN_BASE" -maxdepth 2 -name "places.sqlite" -exec dirname {} \; | head -1)

if [[ -z "$ZEN_PROFILE" ]]; then
    notify-send "Zen Bookmarks" "Could not find Zen Browser profile directory" -u critical
    echo "Error: Zen profile not found in $ZEN_BASE"
    exit 1
fi

BOOKMARKS_DB="$ZEN_PROFILE/places.sqlite"

if [[ ! -f "$BOOKMARKS_DB" ]]; then
    notify-send "Zen Bookmarks" "Bookmarks database not found" -u critical
    echo "Error: places.sqlite not found at $BOOKMARKS_DB"
    exit 1
fi

# Create temporary copy to avoid database lock
TEMP_DB="/tmp/zen_bookmarks_$$.sqlite"
cp "$BOOKMARKS_DB" "$TEMP_DB"

# Extract bookmarks WITH folder hierarchy
# Only get actual URLs (not folders), but show their parent folder
bookmarks=$(sqlite3 "$TEMP_DB" "
    WITH RECURSIVE folder_path(id, parent, title, path) AS (
        -- Base case: root folders
        SELECT id, parent, title, title
        FROM moz_bookmarks
        WHERE parent IN (SELECT id FROM moz_bookmarks WHERE title IN ('Bookmarks Menu', 'Bookmarks Toolbar', 'Other Bookmarks'))
        
        UNION ALL
        
        -- Recursive case: child folders
        SELECT b.id, b.parent, b.title, 
               CASE 
                   WHEN fp.path IS NULL THEN b.title
                   ELSE fp.path || ' > ' || b.title
               END
        FROM moz_bookmarks b
        JOIN folder_path fp ON b.parent = fp.id
    )
    SELECT DISTINCT 
        COALESCE(fp.path, 'Root') as folder,
        b.title, 
        p.url
    FROM moz_bookmarks b
    JOIN moz_places p ON b.fk = p.id
    LEFT JOIN folder_path fp ON b.parent = fp.id
    WHERE b.title IS NOT NULL 
        AND b.title != ''
        AND p.url LIKE 'http%'
        AND b.type = 1  -- type 1 = bookmark (not folder)
    ORDER BY b.dateAdded DESC;
" 2>/dev/null | awk -F'|' '{
    folder = $1
    title = $2
    url = $3
    
    # Add icons based on URL
    if (url ~ /youtube/) icon = " "
    else if (url ~ /github/) icon = " "
    else if (url ~ /reddit/) icon = " "
    else if (url ~ /twitter|x\.com/) icon = " "
    else if (url ~ /stackoverflow/) icon = " "
    else if (url ~ /chatgpt|openai|claude|anthropic/) icon = "🤖"
    else if (url ~ /google/) icon = " "
    else if (url ~ /monkeytype/) icon = " "
    else if (url ~ /netflix/) icon = " "
    else if (url ~ /spotify/) icon = " "
    else if (url ~ /anime|aniwatch/) icon = " "
    else if (url ~ /gmail|mail/) icon = " "
    else if (url ~ /drive\.google/) icon = " "
    else if (url ~ /docs\.google/) icon = " "
    else if (url ~ /amazon/) icon = " "
    else if (url ~ /wikipedia/) icon = " "
    else if (url ~ /twitch/) icon = " "
    else if (url ~ /discord/) icon = "󰙯 "
    else if (url ~ /linkedin/) icon = " "
    else icon = " "
    
    # Format: icon + title, folder path with separator, URL (hidden)
    printf "%s <b>%s</b>\n    <span foreground=\"#7f849c\">%s</span> │ <span foreground=\"#585b70\" size=\"small\">%s</span>\n", icon, title, folder, url
}')

# Clean up
rm -f "$TEMP_DB"

if [[ -z "$bookmarks" ]]; then
    notify-send "Zen Bookmarks" "No bookmarks found" -u normal
    exit 1
fi

# Add quit option
menu_items="$bookmarks
 Quit"

# Show rofi with aesthetic styling
choice=$(echo "$menu_items" | rofi -dmenu -i \
    -l 15 \
    -p '󰃀  Zen Bookmarks' \
    -theme-str 'window { 
        width: 60%; 
        border-radius: 12px;
        border: 2px;
        border-color: #cba6f7;
    }' \
    -theme-str 'mainbox { 
        padding: 12px; 
        spacing: 12px;
    }' \
    -theme-str 'inputbar { 
        padding: 12px; 
        border-radius: 8px; 
        background-color: #1e1e2e;
        children: [prompt, textbox-prompt-colon, entry];
    }' \
    -theme-str 'prompt { 
        text-color: #cba6f7;
        font: "JetBrainsMono Nerd Font 11";
    }' \
    -theme-str 'textbox-prompt-colon {
        expand: false;
        str: "│";
        margin: 0 8px 0 8px;
        text-color: #585b70;
    }' \
    -theme-str 'entry { 
        text-color: #cdd6f4;
        placeholder: "Type to search...";
        placeholder-color: #585b70;
    }' \
    -theme-str 'listview { 
        lines: 15; 
        spacing: 4px;
        scrollbar: true;
        border-radius: 8px;
        padding: 8px;
    }' \
    -theme-str 'scrollbar {
        width: 4px;
        handle-width: 6px;
        handle-color: #585b70;
        border-radius: 4px;
    }' \
    -theme-str 'element { 
        padding: 10px 12px;
        border-radius: 6px;
        spacing: 8px;
    }' \
    -theme-str 'element selected { 
        background-color: #313244;
        text-color: #cdd6f4;
        border: 1px;
        border-color: #cba6f7;
    }' \
    -theme-str 'element-text { 
        highlight: bold;
        vertical-align: 0.5;
    }' \
    -theme-str 'element-text selected {
        text-color: #cdd6f4;
    }' \
    -theme-str 'message {
        padding: 8px;
        border-radius: 6px;
        background-color: #1e1e2e;
    }' \
    -theme-str 'textbox {
        text-color: #cba6f7;
    }' \
    -markup-rows \
    -matching fuzzy \
    -no-custom)

if [[ "$choice" == *"Quit"* ]] || [[ -z "$choice" ]]; then
    exit 0
fi

# Extract URL (third line of the selection)
url=$(echo "$choice" | grep -oP 'https?://[^\s]+' | head -1)

if [[ -n "$url" ]]; then
    $BROWSER "$url" &
    disown
    notify-send "Opening Bookmark" "$url" -t 2000
fi
