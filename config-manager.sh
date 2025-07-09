#!/bin/bash

# config-manager.sh
# Manage installation/removal of config folders from ./config/ to ~/.config/

CONFIG_SRC_DIR="config"
CONFIG_DEST_DIR="$HOME/.config"

# Helper: List all config folders in $CONFIG_SRC_DIR
list_configs() {
    find "$CONFIG_SRC_DIR" -mindepth 1 -maxdepth 1 -type d -printf "%f\n" 2>/dev/null
}

# Install a single config folder
install_config() {
    local config_name="$1"
    local src="$CONFIG_SRC_DIR/$config_name"
    local dest="$CONFIG_DEST_DIR/$config_name"

    if [[ ! -d "$src" ]]; then
        echo "Error: '$src' does not exist."
        return 1
    fi

    if [[ -e "$dest" ]]; then
        echo "Config '$config_name' already exists in ~/.config/"
        return 0
    fi

    cp -r "$src" "$dest"
    echo "Installed '$config_name'"
}

# Remove a single config folder
remove_config() {
    local config_name="$1"
    local dest="$CONFIG_DEST_DIR/$config_name"

    if [[ ! -e "$dest" ]]; then
        echo "Config '$config_name' not found in ~/.config/"
        return 1
    fi

    rm -rf "$dest"
    echo "Removed '$config_name' from ~/.config/"
}

# Install all configs
install_all() {
    local count=0
    for config in $(list_configs); do
        install_config "$config" && ((count++))
    done
    echo "Installed $count config(s)."
}

# Remove all configs
remove_all() {
    local count=0
    for config in $(list_configs); do
        remove_config "$config" && ((count++))
    done
    
    echo "Removed $count config(s)."
}

# List configs and their status
list_status() {
    printf "Configs in '%s':\n" "$CONFIG_SRC_DIR"
    printf "====================\n"
    for config in $(list_configs); do
        if [[ -e "$CONFIG_DEST_DIR/$config" ]]; then
            echo "  ✔ $config"
        else
            echo "  ✘ $config"
        fi
    done
    echo ""
    echo "Use '$0 install <name>' or '$0 remove <name>' for individual configs."
}

usage() {
    echo "Usage: $0 {install-all|remove-all|install <name>|remove <name>|list}"
    echo "  install-all         - Install all config folders to ~/.config/"
    echo "  remove-all          - Remove all config folders from ~/.config/"
    echo "  install <name>      - Install a specific config folder"
    echo "  remove <name>       - Remove a specific config folder"
    echo "  list                - List all config folders and their status"
    exit 1
}

case "$1" in
    install-all)
        install_all
        ;;
    remove-all)
        remove_all
        ;;
    install)
        install_config "$2"
        ;;
    remove)
        remove_config "$2"
        ;;
    list)
        list_status
        ;;
    *)
        usage
        ;;
esac