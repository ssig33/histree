#!/usr/bin/env bash
# install.sh
# zsh-histree installation script.
set -e

# Determine the installation directory (based on the script location)
INSTALL_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_DIR="${HOME}/.zsh-histree"

# Check if the shell is fish
if [[ "$SHELL" == *"fish" ]]; then
    TARGET_DIR="${HOME}/.fish-histree"
    echo "Installing fish-histree to ${TARGET_DIR} ..."

    # Create target directory and copy files
    mkdir -p "${TARGET_DIR}/bin"
    cp -r "${INSTALL_DIR}/histree.fish" "${TARGET_DIR}/"
    cp bin/histree "${TARGET_DIR}/bin/"

    # Add configuration to config.fish if not already present
    CONFIG_FISH="${HOME}/.config/fish/config.fish"
    SOURCE_LINE="source ${TARGET_DIR}/histree.fish"

    if grep -qF "$SOURCE_LINE" "${CONFIG_FISH}"; then
        echo "Your config.fish already sources fish-histree."
    else
        echo "" >> "${CONFIG_FISH}"
        echo "# fish-histree configuration" >> "${CONFIG_FISH}"
        echo "set -g HISTREE_DB \"\$HOME/.histree.db\"" >> "${CONFIG_FISH}"
        echo "set -g HISTREE_LIMIT 100" >> "${CONFIG_FISH}"
        echo "$SOURCE_LINE" >> "${CONFIG_FISH}"
        echo "Added configuration to ${CONFIG_FISH}."
    fi

    echo "Installation complete. Please restart your terminal or run 'source ~/.config/fish/config.fish' to activate fish-histree."
else
    echo "Installing zsh-histree to ${TARGET_DIR} ..."

    # Create target directory and copy files
    mkdir -p "${TARGET_DIR}/bin"
    cp -r "${INSTALL_DIR}/histree.zsh" "${TARGET_DIR}/"
    cp bin/histree "${TARGET_DIR}/bin/"

    # Add configuration to .zshrc if not already present
    ZSHRC="${HOME}/.zshrc"
    SOURCE_LINE="source ${TARGET_DIR}/histree.zsh"

    # Default configurations
    DB_CONFIG="export HISTREE_DB=\"\${HOME}/.histree.db\""
    LIMIT_CONFIG="export HISTREE_LIMIT=100"

    if grep -qF "$SOURCE_LINE" "${ZSHRC}"; then
        echo "Your .zshrc already sources zsh-histree."
    else
        echo "" >> "${ZSHRC}"
        echo "# zsh-histree configuration" >> "${ZSHRC}"
        echo "$DB_CONFIG" >> "${ZSHRC}"
        echo "$LIMIT_CONFIG" >> "${ZSHRC}"
        echo "$SOURCE_LINE" >> "${ZSHRC}"
        echo "Added configuration to ${ZSHRC}."
    fi

    echo "Installation complete. Please restart your terminal or run 'source ~/.zshrc' to activate zsh-histree."
fi
