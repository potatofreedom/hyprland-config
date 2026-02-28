#!/bin/bash
# ╔══════════════════════════════════════════╗
# ║  Wofi Launcher — Wallpaper + Search      ║
# ║  Left: wallpaper preview                 ║
# ║  Right: app search & list                ║
# ╚══════════════════════════════════════════╝

# Toggle — kill if already running
if pgrep -x wofi > /dev/null; then
    pkill wofi
    exit 0
fi

# Get current wallpaper path
WALLPAPER=""
if [ -f "$HOME/.current_wallpaper" ]; then
    WALLPAPER=$(cat "$HOME/.current_wallpaper" 2>/dev/null)
fi

# Fallback: try swww query
if [ -z "$WALLPAPER" ] || [ ! -f "$WALLPAPER" ]; then
    WALLPAPER=$(swww query 2>/dev/null | head -1 | awk -F'image: ' '{print $2}')
fi

# Generate CSS with embedded wallpaper
STYLE_FILE="$HOME/.config/wofi/style-dynamic.css"

if [ -n "$WALLPAPER" ] && [ -f "$WALLPAPER" ]; then
    BG_RULE="background-image: url('${WALLPAPER}');"
else
    BG_RULE="background-color: rgba(30, 30, 46, 0.6);"
fi

cat > "$STYLE_FILE" << CSSEOF
/* Wofi — Wallpaper + App Launcher */

window {
    margin: 0;
    border: none;
    border-radius: 16px;
    ${BG_RULE}
    background-size: cover;
    background-position: center;
    font-family: "JetBrainsMono Nerd Font";
    font-size: 14px;
}

#outer-box {
    margin: 0;
    margin-left: 300px;
    padding: 20px 16px 16px 16px;
    border: none;
    border-radius: 0 16px 16px 0;
    background-color: rgba(17, 17, 27, 0.85);
}

#input {
    all: unset;
    margin: 4px 4px 14px 4px;
    padding: 13px 18px;
    border-radius: 12px;
    background-color: rgba(30, 30, 46, 0.5);
    color: #cdd6f4;
    font-size: 15px;
    border-bottom: 1px solid rgba(116, 199, 236, 0.1);
}

#input:focus {
    background-color: rgba(30, 30, 46, 0.65);
    border-bottom: 1px solid rgba(116, 199, 236, 0.2);
}

#inner-box {
    margin: 0 4px;
    border: none;
}

#scroll {
    margin: 0;
    border: none;
}

#text {
    margin: 0 8px;
    color: rgba(205, 214, 244, 0.9);
}

#entry {
    padding: 10px 14px;
    border-radius: 12px;
    margin: 2px 0;
}

#entry:selected {
    background-color: rgba(116, 199, 236, 0.08);
}

#entry:selected #text {
    color: #74c7ec;
}

#img {
    margin-right: 14px;
    border-radius: 8px;
}
CSSEOF

# Launch wofi with the generated style
wofi --show drun --style "$STYLE_FILE"
