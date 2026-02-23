#!/bin/bash
# ╔══════════════════════════════════════════════════╗
# ║  Обои + автоматическая генерация цветов          ║
# ║  swww + wallust → Waybar, Kitty, Wofi, Dunst,   ║
# ║  Hyprland borders, cava                          ║
# ╚══════════════════════════════════════════════════╝

WALLPAPER_DIR="$HOME/Pictures/Wallpapers"

if [ -z "$1" ]; then
    WALLPAPER=$(find "$WALLPAPER_DIR" -type f \( -name "*.jpg" -o -name "*.png" -o -name "*.jpeg" -o -name "*.webp" \) | shuf -n 1)
else
    WALLPAPER="$1"
fi

if [ -z "$WALLPAPER" ]; then
    echo "No wallpapers in $WALLPAPER_DIR"
    exit 1
fi

# Обои + генерация цветов параллельно
swww img "$WALLPAPER" \
    --transition-type grow \
    --transition-pos "0.925,0.977" \
    --transition-step 90 \
    --transition-fps 60 \
    --transition-duration 2 &

echo "$WALLPAPER" > "$HOME/.current_wallpaper"

# Генерация цветов (пока swww анимирует — wallust уже работает)
if command -v wallust &>/dev/null; then
    wallust run "$WALLPAPER" 2>/dev/null

    # Применяем все цвета параллельно
    {
        # Hyprland — перечитать borders
        hyprctl reload 2>/dev/null

        # Kitty — обновить цвета во всех окнах
        for pid in $(pgrep -x kitty); do
            kill -SIGUSR1 "$pid" 2>/dev/null
        done

        # Dunst — перезапуск (единственный способ применить новые цвета)
        if pgrep -x dunst &>/dev/null; then
            pkill dunst 2>/dev/null
            dunst &
            disown
        fi
    } &
fi

wait
echo "Wallpaper set: $WALLPAPER"
