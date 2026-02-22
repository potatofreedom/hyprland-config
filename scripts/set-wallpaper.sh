#!/bin/bash
# Скрипт установки обоев с плавной анимацией

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

if [ -z "$1" ]; then
    # Если не указан файл — случайные обои
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)
else
    WALLPAPER="$1"
fi

if [ -z "$WALLPAPER" ]; then
    echo "No wallpapers in $WALLPAPER_DIR"
    exit 1
fi

# Устанавливаем обои с анимацией
swww img "$WALLPAPER" \
    --transition-type grow \
    --transition-pos "0.925,0.977" \
    --transition-step 90 \
    --transition-fps 60 \
    --transition-duration 2

echo "$WALLPAPER" > "$HOME/.current_wallpaper"

echo "Wallpaper set: $WALLPAPER"
