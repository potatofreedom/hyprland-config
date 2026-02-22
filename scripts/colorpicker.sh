#!/bin/bash
# Color Picker — копирует HEX-код цвета пикселя в буфер обмена

COLOR=$(hyprpicker -a -f hex)
if [ -n "$COLOR" ]; then
    echo -n "$COLOR" | wl-copy
    notify-send "Color Picker" "Color $COLOR copied!" -i color-select
fi
