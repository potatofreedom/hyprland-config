#!/bin/bash
# ╔══════════════════════════════════════════════════╗
# ║  Hyprland Config Installer                       ║
# ║  Копирует конфиги из репозитория в ~/.config     ║
# ╚══════════════════════════════════════════════════╝

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Цвета
GREEN='\033[0;32m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${PURPLE}"
echo "  ╔══════════════════════════════════════╗"
echo "  ║   Hyprland Config Installer          ║"
echo "  ║   Catppuccin Mocha Pastel Theme      ║"
echo "  ╚══════════════════════════════════════╝"
echo -e "${NC}"

# ===== Бэкап существующих конфигов =====
echo -e "${YELLOW}[1/5] Creating backups...${NC}"
BACKUP_DIR="$HOME/.config-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

for dir in hypr kitty fish waybar wofi dunst cava wlogout fastfetch; do
    if [ -d "$HOME/.config/$dir" ]; then
        cp -r "$HOME/.config/$dir" "$BACKUP_DIR/"
        echo "  Backed up: ~/.config/$dir"
    fi
done

if [ -f "$HOME/.config/starship.toml" ]; then
    cp "$HOME/.config/starship.toml" "$BACKUP_DIR/"
    echo "  Backed up: ~/.config/starship.toml"
fi

echo -e "${GREEN}  Backups saved to: $BACKUP_DIR${NC}"

# ===== Создание директорий =====
echo -e "${YELLOW}[2/5] Creating directories...${NC}"
mkdir -p "$HOME/.config/hypr"
mkdir -p "$HOME/.config/kitty"
mkdir -p "$HOME/.config/fish"
mkdir -p "$HOME/.config/waybar"
mkdir -p "$HOME/.config/wofi"
mkdir -p "$HOME/.config/dunst"
mkdir -p "$HOME/.config/cava"
mkdir -p "$HOME/.config/wlogout"
mkdir -p "$HOME/.config/fastfetch"
mkdir -p "$HOME/.local/bin"
mkdir -p "$HOME/Pictures/Wallpapers"
mkdir -p "$HOME/Pictures/Screenshots"

# ===== Копирование конфигов =====
echo -e "${YELLOW}[3/5] Copying config files...${NC}"

# Hyprland
cp "$SCRIPT_DIR/hypr/hyprland.conf" "$HOME/.config/hypr/"
cp "$SCRIPT_DIR/hypr/env.conf" "$HOME/.config/hypr/"
cp "$SCRIPT_DIR/hypr/hyprlock.conf" "$HOME/.config/hypr/"
cp "$SCRIPT_DIR/hypr/hypridle.conf" "$HOME/.config/hypr/"
echo -e "  ${BLUE}Hyprland${NC} configs installed"

# Kitty
cp "$SCRIPT_DIR/kitty/kitty.conf" "$HOME/.config/kitty/"
echo -e "  ${BLUE}Kitty${NC} config installed"

# Fish
cp "$SCRIPT_DIR/fish/config.fish" "$HOME/.config/fish/"
echo -e "  ${BLUE}Fish${NC} config installed"

# Waybar
cp "$SCRIPT_DIR/waybar/config.jsonc" "$HOME/.config/waybar/"
cp "$SCRIPT_DIR/waybar/style.css" "$HOME/.config/waybar/"
echo -e "  ${BLUE}Waybar${NC} config installed"

# Wofi
cp "$SCRIPT_DIR/wofi/config" "$HOME/.config/wofi/"
cp "$SCRIPT_DIR/wofi/style.css" "$HOME/.config/wofi/"
echo -e "  ${BLUE}Wofi${NC} config installed"

# Dunst
cp "$SCRIPT_DIR/dunst/dunstrc" "$HOME/.config/dunst/"
echo -e "  ${BLUE}Dunst${NC} config installed"

# cava
cp "$SCRIPT_DIR/cava/config" "$HOME/.config/cava/"
echo -e "  ${BLUE}cava${NC} config installed"

# wlogout
cp "$SCRIPT_DIR/wlogout/layout" "$HOME/.config/wlogout/"
echo -e "  ${BLUE}wlogout${NC} config installed"

# Fastfetch
cp "$SCRIPT_DIR/fastfetch/config.jsonc" "$HOME/.config/fastfetch/"
cp "$SCRIPT_DIR/fastfetch/logo.txt" "$HOME/.config/fastfetch/"
echo -e "  ${BLUE}Fastfetch${NC} config installed"

# Starship
cp "$SCRIPT_DIR/starship/starship.toml" "$HOME/.config/starship.toml"
echo -e "  ${BLUE}Starship${NC} config installed"

# ===== Скрипты =====
echo -e "${YELLOW}[4/5] Installing scripts...${NC}"

cp "$SCRIPT_DIR/scripts/set-wallpaper.sh" "$HOME/.local/bin/"
cp "$SCRIPT_DIR/scripts/screenshot.sh" "$HOME/.local/bin/"
cp "$SCRIPT_DIR/scripts/colorpicker.sh" "$HOME/.local/bin/"
chmod +x "$HOME/.local/bin/set-wallpaper.sh"
chmod +x "$HOME/.local/bin/screenshot.sh"
chmod +x "$HOME/.local/bin/colorpicker.sh"
echo -e "  Scripts installed to ~/.local/bin/"

# ===== Системные конфиги (требуют sudo) =====
echo -e "${YELLOW}[5/5] System configs (requires sudo)...${NC}"

read -p "  Install system configs (NVIDIA, SDDM, iwd)? [y/N] " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    # NVIDIA
    sudo cp "$SCRIPT_DIR/system/nvidia.conf" /etc/modprobe.d/nvidia.conf
    echo -e "  ${BLUE}NVIDIA${NC} modprobe config installed"

    sudo mkdir -p /etc/pacman.d/hooks
    sudo cp "$SCRIPT_DIR/system/nvidia.hook" /etc/pacman.d/hooks/nvidia.hook
    echo -e "  ${BLUE}NVIDIA${NC} pacman hook installed"

    # iwd
    sudo mkdir -p /etc/iwd
    sudo cp "$SCRIPT_DIR/system/iwd-main.conf" /etc/iwd/main.conf
    echo -e "  ${BLUE}iwd${NC} config installed"

    # SDDM
    sudo mkdir -p /etc/sddm.conf.d
    sudo cp "$SCRIPT_DIR/sddm/theme.conf" /etc/sddm.conf.d/theme.conf
    echo -e "  ${BLUE}SDDM${NC} theme config installed"

    if [ -d "/usr/share/sddm/themes/sugar-candy" ]; then
        sudo cp "$SCRIPT_DIR/sddm/sugar-candy-theme.conf" /usr/share/sddm/themes/sugar-candy/theme.conf
        sudo mkdir -p /usr/share/sddm/themes/sugar-candy/Backgrounds
        echo -e "  ${BLUE}Sugar Candy${NC} theme customized"
    else
        echo -e "  ${YELLOW}Sugar Candy theme not found, skipping customization${NC}"
    fi
fi

# ===== Готово =====
echo ""
echo -e "${GREEN}╔══════════════════════════════════════════╗${NC}"
echo -e "${GREEN}║  Installation complete!                  ║${NC}"
echo -e "${GREEN}╚══════════════════════════════════════════╝${NC}"
echo ""
echo -e "  Backups: ${BLUE}$BACKUP_DIR${NC}"
echo ""
echo -e "  ${PURPLE}Next steps:${NC}"
echo "  1. Put wallpapers in ~/Pictures/Wallpapers/"
echo "  2. Reboot or restart Hyprland (Super+Shift+M)"
echo "  3. Enjoy!"
echo ""
