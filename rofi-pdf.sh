
#!/bin/zsh

# Rofi PDF Launcher with Recent Files (Zsh optimized)
# Location: ~/.local/bin/rofi-pdf

RECENT_FILE="$HOME/.cache/recent-pdfs"
MAX_RECENT=10

# Directories to search
PDF_DIRS=(
    "$HOME/Downloads"
    "$HOME/Documents"
    "$HOME/Books"
)

# Create cache directory
mkdir -p "${RECENT_FILE:h}"
touch "$RECENT_FILE"

# Mode selection
mode=$(echo -e "Recent\nBrowse All\nSearch" | rofi -dmenu -p "PDF Mode" -i)

case "$mode" in
    "Recent")
        # Show recent PDFs (reverse order, newest first)
        pdf_list=$(tac "$RECENT_FILE" 2>/dev/null | head -n "$MAX_RECENT")
        ;;
    "Browse All")
        # Find all PDFs
        pdf_list=$(find "${PDF_DIRS[@]}" -type f -iname "*.pdf" 2>/dev/null | sort)
        ;;
    "Search")
        # Search by name
        search_term=$(rofi -dmenu -p "Search PDF" -i)
        if [[ -n "$search_term" ]]; then
            pdf_list=$(find "${PDF_DIRS[@]}" -type f -iname "*${search_term}*.pdf" 2>/dev/null | sort)
        else
            exit 0
        fi
        ;;
    *)
        exit 0
        ;;
esac

# Exit if no PDFs
if [[ -z "$pdf_list" ]]; then
    rofi -e "No PDFs found"
    exit 1
fi

# Format list for display (zsh associative array)
typeset -A pdf_map
formatted_list=""

while IFS= read -r pdf; do
    [[ -f "$pdf" ]] || continue
    
    # Use zsh path modifiers
    filename="${pdf:t}"           # basename
    parent_dir="${${pdf:h}:t}"    # parent directory name
    
    display_name="$filename [$parent_dir]"
    pdf_map[$display_name]="$pdf"
    formatted_list+="$display_name"$'\n'
done <<< "$pdf_list"

# Select PDF
selected=$(echo -e "$formatted_list" | rofi -dmenu -i -p "📄 Select PDF" -theme-str 'window {width: 60%;}')

# Open and update recent
if [[ -n "$selected" ]]; then
    pdf_path="${pdf_map[$selected]}"
    
    # Open with zathura
    zathura "$pdf_path" &!
    
    # Update recent files (remove duplicates, add to top)
    grep -vF "$pdf_path" "$RECENT_FILE" > "${RECENT_FILE}.tmp" 2>/dev/null || true
    echo "$pdf_path" >> "${RECENT_FILE}.tmp"
    tail -n "$MAX_RECENT" "${RECENT_FILE}.tmp" > "$RECENT_FILE"
    rm -f "${RECENT_FILE}.tmp"
fi
