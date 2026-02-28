# ===== Fish Shell Config =====

# Убираем приветствие
set -g fish_greeting

# Алиасы
alias ls='eza --icons --group-directories-first'
alias ll='eza -la --icons --group-directories-first'
alias lt='eza --tree --icons --level=2'
alias cat='bat'
alias vim='nvim'
alias update='sudo pacman -Syu && yay -Sua'
alias cleanup='sudo pacman -Rns (pacman -Qdtq)'
alias ff='fastfetch'

# PATH
fish_add_path ~/.local/bin
fish_add_path ~/.rbenv/bin

# rbenv
if type -q rbenv
    status --is-interactive; and rbenv init - fish | source
end

# Переменные
set -gx EDITOR nvim
set -gx VISUAL nvim
set -gx TERMINAL kitty
set -gx BROWSER firefox

# Starship prompt
if type -q starship
    starship init fish | source
end

# Zoxide (умный cd)
if type -q zoxide
    zoxide init fish | source
end

