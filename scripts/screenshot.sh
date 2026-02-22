#!/bin/bash
# Скрипт скриншотов для Hyprland

SCREENSHOT_DIR="$HOME/Pictures/Screenshots"
mkdir -p "$SCREENSHOT_DIR"
FILENAME="$SCREENSHOT_DIR/screenshot_$(date +%Y%m%d_%H%M%S).png"

case "$1" in
    "full")
        grim "$FILENAME"
        ;;
    "area")
        grim -g "$(slurp -d)" "$FILENAME"
        ;;
    "window")
        grim -g "$(hyprctl activewindow -j | jq -r '"\(.at[0]),\(.at[1]) \(.size[0])x\(.size[1])"')" "$FILENAME"
        ;;
    "area-clipboard")
        grim -g "$(slurp -d)" - | wl-copy
        notify-send "Screenshot" "Copied to clipboard" -i camera
        exit 0
        ;;
    *)
        echo "Usage: screenshot.sh [full|area|window|area-clipboard]"
        exit 1
        ;;
esac

# Копируем в буфер обмена
wl-copy < "$FILENAME"
notify-send "Screenshot" "Saved: $FILENAME" -i camera -a "Screenshot"
