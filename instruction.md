# Hyprland Dotfiles — Catppuccin Mocha Pastel

> **Maibenben X525** | Intel i5-12400 | NVIDIA RTX 4060 Mobile | 144Hz  
> Минималистичная система в пастельных тонах

## Структура репозитория

```
hyprland-config/
├── install.sh              # Скрипт установки всех конфигов
├── hypr/
│   ├── hyprland.conf       # Основной конфиг Hyprland
│   ├── env.conf            # Переменные окружения (NVIDIA/Wayland)
│   ├── hyprlock.conf       # Lock screen
│   └── hypridle.conf       # Автоблокировка/suspend
├── kitty/
│   └── kitty.conf          # Терминал + Catppuccin цвета
├── fish/
│   └── config.fish         # Fish shell
├── waybar/
│   ├── config.jsonc        # Панель — модули
│   └── style.css           # Панель — стили
├── wofi/
│   ├── config              # Лаунчер (Super+D)
│   └── style.css           # Лаунчер — стили
├── dunst/
│   └── dunstrc             # Уведомления
├── cava/
│   └── config              # Аудио-визуализатор
├── wlogout/
│   └── layout              # Экран выхода
├── fastfetch/
│   ├── config.jsonc        # Системная информация
│   └── logo.txt            # ASCII-лого
├── starship/
│   └── starship.toml       # Prompt для терминала
├── scripts/
│   ├── set-wallpaper.sh    # Обои с анимацией
│   ├── screenshot.sh       # Скриншоты
│   └── colorpicker.sh      # Пипетка цвета
├── sddm/
│   ├── theme.conf          # Конфиг SDDM
│   └── sugar-candy-theme.conf  # Тема Sugar Candy
└── system/
    ├── nvidia.conf         # NVIDIA modprobe
    ├── nvidia.hook         # Pacman hook для NVIDIA
    └── iwd-main.conf       # Wi-Fi (iwd)
```

---

## Быстрая установка (после установки Arch)

```bash
cd ~
git clone https://github.com/ТВОЙ_ЮЗЕРНЕЙМ/hyprland-config.git
cd hyprland-config
chmod +x install.sh
./install.sh
```

Скрипт автоматически:
- Сделает бэкап существующих конфигов
- Скопирует все файлы в `~/.config/`
- Установит скрипты в `~/.local/bin/`
- Предложит установить системные конфиги (NVIDIA, SDDM, iwd)

---

## Полная инструкция установки Arch Linux с нуля

### 1. Подготовка

1. Скачай ISO с https://archlinux.org/download/
2. Запиши на флешку: `dd if=archlinux-*.iso of=/dev/sdX bs=4M status=progress oflag=sync`
3. В BIOS: отключи **Secure Boot**, включи **UEFI**, загрузка с USB первая

### 2. Подключение к Wi-Fi

```bash
iwctl
# Внутри iwctl:
device list
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "Имя_Сети"
exit

ping -c 3 archlinux.org
```

### 3. Разметка диска

```bash
timedatectl set-ntp true

# Определяем диск
lsblk

# Очищаем и размечаем
sgdisk --zap-all /dev/nvme0n1
sgdisk -o /dev/nvme0n1
sgdisk -n 1:0:+512M -t 1:ef00 -c 1:"EFI" /dev/nvme0n1
sgdisk -n 2:0:+16G -t 2:8200 -c 2:"Swap" /dev/nvme0n1
sgdisk -n 3:0:0 -t 3:8300 -c 3:"Root" /dev/nvme0n1
```

| Раздел | Размер | Тип | Назначение |
|--------|--------|-----|------------|
| `/dev/nvme0n1p1` | 512M | EFI (ef00) | Загрузчик |
| `/dev/nvme0n1p2` | 16G | Swap (8200) | Swap + гибернация |
| `/dev/nvme0n1p3` | Всё остальное | Linux (8300) | Корень `/` |

### 4. Форматирование и монтирование

```bash
mkfs.fat -F 32 -n EFI /dev/nvme0n1p1
mkswap -L Swap /dev/nvme0n1p2
swapon /dev/nvme0n1p2
mkfs.ext4 -L Root /dev/nvme0n1p3

mount /dev/nvme0n1p3 /mnt
mount --mkdir /dev/nvme0n1p1 /mnt/boot
```

### 5. Установка базовой системы

```bash
reflector --country Russia,Germany,Finland --age 12 --protocol https --sort rate --save /etc/pacman.d/mirrorlist

pacstrap -K /mnt \
  base base-devel linux linux-headers linux-firmware \
  intel-ucode \
  iwd dhcpcd \
  nano vim \
  git wget curl \
  man-db man-pages \
  dosfstools mtools \
  grub efibootmgr \
  sudo

genfstab -U /mnt >> /mnt/etc/fstab
```

### 6. Настройка системы (chroot)

```bash
arch-chroot /mnt

# Часовой пояс
ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc

# Локализация
nano /etc/locale.gen
# Раскомментируй: en_US.UTF-8 UTF-8 и ru_RU.UTF-8 UTF-8
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf

# Имя хоста
echo "maibenben" > /etc/hostname
nano /etc/hosts
# Добавь:
# 127.0.0.1   localhost
# ::1         localhost
# 127.0.1.1   maibenben.localdomain   maibenben

# Пароли и пользователь
passwd
useradd -m -G wheel,video,audio,input,storage -s /bin/bash danil
passwd danil
EDITOR=nano visudo
# Раскомментируй: %wheel ALL=(ALL:ALL) ALL

# Сервисы
systemctl enable iwd.service
systemctl enable dhcpcd.service
systemctl enable systemd-resolved.service

# iwd конфиг (или используй install.sh позже)
mkdir -p /etc/iwd
nano /etc/iwd/main.conf
# Содержимое — см. system/iwd-main.conf из репозитория

# GRUB
grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
grub-mkconfig -o /boot/grub/grub.cfg

# Multilib (для 32-bit библиотек NVIDIA)
nano /etc/pacman.conf
# Раскомментируй [multilib] и Include
# Добавь: ParallelDownloads = 5, Color, ILoveCandy
pacman -Sy

exit
umount -R /mnt
reboot
```

### 7. Драйверы NVIDIA + Intel

```bash
# Подключись к Wi-Fi через iwctl

# yay (AUR)
sudo pacman -S --needed git base-devel
cd /tmp && git clone https://aur.archlinux.org/yay-bin.git && cd yay-bin && makepkg -si && cd ~

# Intel
sudo pacman -S mesa intel-media-driver vulkan-intel lib32-mesa lib32-vulkan-intel

# NVIDIA (nvidia-open для ядер 6.11+, если не работает — попробуй nvidia)
sudo pacman -S nvidia-open nvidia-utils lib32-nvidia-utils nvidia-settings nvidia-prime opencl-nvidia lib32-opencl-nvidia

# NVIDIA modprobe (или используй install.sh)
sudo cp ~/hyprland-config/system/nvidia.conf /etc/modprobe.d/nvidia.conf

# initramfs — добавь в MODULES
sudo nano /etc/mkinitcpio.conf
# MODULES=(nvidia nvidia_modeset nvidia_uvm nvidia_drm)
sudo mkinitcpio -P

# GRUB
sudo nano /etc/default/grub
# GRUB_CMDLINE_LINUX_DEFAULT="loglevel=3 quiet nvidia_drm.modeset=1 nvidia_drm.fbdev=1"
sudo grub-mkconfig -o /boot/grub/grub.cfg

# Pacman hook (или используй install.sh)
sudo mkdir -p /etc/pacman.d/hooks
sudo cp ~/hyprland-config/system/nvidia.hook /etc/pacman.d/hooks/nvidia.hook

# Сервисы suspend/hibernate
sudo systemctl enable nvidia-suspend.service
sudo systemctl enable nvidia-hibernate.service
sudo systemctl enable nvidia-resume.service

sudo reboot
# Проверка: nvidia-smi
```

### 8. Установка Hyprland и всех пакетов

```bash
# Основные пакеты
sudo pacman -S \
  hyprland \
  xdg-desktop-portal-hyprland xdg-desktop-portal-gtk xdg-utils xdg-user-dirs \
  qt5-wayland qt6-wayland \
  polkit-kde-agent \
  pipewire pipewire-alsa pipewire-audio pipewire-jack pipewire-pulse wireplumber \
  grim slurp wl-clipboard cliphist \
  brightnessctl playerctl pamixer pavucontrol \
  nwg-look qt5ct kvantum \
  ttf-jetbrains-mono-nerd ttf-font-awesome otf-font-awesome \
  noto-fonts noto-fonts-cjk noto-fonts-emoji \
  papirus-icon-theme gnome-themes-extra gtk3 gtk4 \
  kitty fish waybar wofi dunst cava \
  thunar thunar-volman gvfs tumbler ffmpegthumbnailer \
  imv mpv neovim \
  eza bat fd ripgrep fzf btop zoxide starship \
  unzip p7zip tree \
  bluez bluez-utils blueman \
  easyeffects \
  fastfetch \
  libnotify jq \
  xorg-xwayland xorg-xlsclients xorg-xhost xorg-xrandr

# AUR пакеты
yay -S \
  hyprpicker swww wlogout \
  sddm-git sddm-sugar-candy-git \
  hyprlock hypridle \
  bibata-cursor-theme \
  visual-studio-code-bin

# Директории
xdg-user-dirs-update

# SDDM
sudo systemctl enable sddm.service

# Bluetooth
sudo systemctl enable --now bluetooth.service
# В /etc/bluetooth/main.conf поменяй AutoEnable=true

# Аудио
systemctl --user enable pipewire.service pipewire-pulse.service wireplumber.service

# Fish shell
chsh -s /usr/bin/fish

# Fisher (менеджер плагинов Fish)
fish -c "curl -sL https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish | source && fisher install jorgebucaran/fisher"
fish -c "fisher install jethrokuan/z"
fish -c "fisher install PatrickF1/fzf.fish"
fish -c "fisher install jorgebucaran/autopair.fish"

# VS Code на Wayland
echo "--ozone-platform=wayland" > ~/.config/code-flags.conf
```

### 9. Установка конфигов из репозитория

```bash
cd ~/hyprland-config
chmod +x install.sh
./install.sh
```

### 10. Перезагрузка

```bash
sudo reboot
```

SDDM запустится, выбери **Hyprland**, введи пароль.

---

## Горячие клавиши

| Комбинация | Действие |
|------------|----------|
| `Super + Enter` | Терминал (Kitty) |
| `Super + D` | Лаунчер (Wofi) |
| `Super + Q` | Закрыть окно |
| `Super + F` | Fullscreen |
| `Super + V` | Плавающее окно |
| `Super + E` | Файловый менеджер |
| `Super + L` | Блокировка экрана |
| `Super + Escape` | Экран выхода (wlogout) |
| `Super + 1-0` | Переключить воркспейс |
| `Super + Shift + 1-0` | Переместить окно в воркспейс |
| `Super + Shift + S` | Скриншот области в буфер |
| `Print` | Скриншот всего экрана |
| `Super + Shift + C` | Color Picker |
| `Super + Shift + V` | Менеджер буфера обмена |
| `Super + Shift + W` | Случайные обои |
| `Super + Shift + A` | cava (аудио-визуализатор) |
| `Super + Shift + M` | Выход из Hyprland |
| `Alt + Shift` | Переключить язык (EN/RU) |
| `Super + стрелки` | Фокус |
| `Super + Shift + стрелки` | Переместить окно |
| `Super + Ctrl + стрелки` | Изменить размер |
| `3 пальца тачпад` | Свайп воркспейсов |

---

## Частые проблемы

**Черный экран (NVIDIA):**
```bash
# Из TTY (Ctrl+Alt+F2):
sudo nano /etc/default/grub
# Проверь: nvidia_drm.modeset=1 nvidia_drm.fbdev=1
sudo grub-mkconfig -o /boot/grub/grub.cfg
sudo mkinitcpio -P
sudo reboot
```

**Нет звука:**
```bash
systemctl --user restart pipewire pipewire-pulse wireplumber
```

**Wi-Fi (iwd):**
```bash
iwctl
station wlan0 scan
station wlan0 get-networks
station wlan0 connect "SSID"
exit
```

**Мерцание экрана (NVIDIA):**  
Добавь в `~/.config/hypr/env.conf`:
```
env = WLR_DRM_NO_ATOMIC,1
```

**Логи Hyprland:**
```bash
cat /tmp/hypr/$(ls -t /tmp/hypr/ | head -1)/hyprland.log | tail -50
```

---

## План кастомизации 

1. **Wallust/Pywal** — автоматическая генерация цветов из обоев для Waybar, Kitty, Wofi, Dunst, Hyprland borders
2. **Анимированные обои** — через swww можно ставить GIF/видео
3. **Waybar с динамическими цветами** — панель будет менять палитру под обои
4. **cava** — настроим градиент под цвета системы
5. **SDDM тема** — уже настроена Sugar Candy с blur и пастельными цветами
6. **Hyprlock** — уже настроен кастомный lock screen с часами, датой и blur
7. **GTK/Qt темы** — единый стиль Catppuccin для всех приложений
8. **Курсор Bibata** — полная настройка размера и темы
9. **Шрифты** — точная настройка рендеринга
10. **Hyprland спецэффекты** — particles, kawase blur, анимации
