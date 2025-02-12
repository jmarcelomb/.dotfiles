#!/bin/sh

set -e  # Exit immediately if a command exits with a non-zero status

TOOLS_DIR=${TOOLS_DIR:-"$HOME/Tools"}
NEOVIM_DIR="$TOOLS_DIR/neovim"
INSTALL_PREFIX="$NEOVIM_DIR"
OS=$(uname)
DRY_RUN=false

# Colors for logs
RESET="\033[0m"
BOLD="\033[1m"
BLUE="\033[34m"
GREEN="\033[32m"
YELLOW="\033[33m"
RED="\033[31m"

log() {
    echo "${BLUE}[INFO]${RESET} $1"
}

success() {
    echo "${GREEN}[SUCCESS]${RESET} $1"
}

warn() {
    echo "${YELLOW}[WARNING]${RESET} $1"
}

error() {
    echo "${RED}[ERROR]${RESET} $1" >&2
    exit 1
}

check_dependencies() {
    if [ "$OS" = "Linux" ]; then
        log "Checking and installing Linux dependencies..."
        sudo apt-get update
        sudo apt-get install -y ninja-build gettext libtool libtool-bin autoconf automake cmake g++ pkg-config unzip curl
    elif [ "$OS" = "Darwin" ]; then
        log "Checking and installing macOS dependencies..."
        if ! command -v brew >/dev/null 2>&1; then
            warn "Homebrew is not installed. Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        fi
        brew install ninja gettext libtool autoconf automake cmake pkg-config curl
    else
        error "Unsupported OS: $OS"
    fi
}

clone_neovim() {
    if [ -d "$NEOVIM_DIR" ]; then
        warn "Neovim directory already exists."
        read -p "Do you want to delete the existing Neovim folder? (y/n) " yn
        case $yn in
            [Yy]* )
                log "Deleting existing Neovim directory..."
                rm -rf "$NEOVIM_DIR"
                ;;
            [Nn]* )
                log "Exiting without changes..."
                exit 0
                ;;
            * )
                error "Invalid response."
                ;;
        esac
    fi

    log "Cloning Neovim..."
    git clone https://github.com/neovim/neovim.git "$NEOVIM_DIR"
    cd "$NEOVIM_DIR"
    git checkout stable
}

build_and_install_neovim() {
    log "Building Neovim..."
    cd "$NEOVIM_DIR"
    rm -rf build/  # Clear the CMake cache
    make CMAKE_BUILD_TYPE=Release CMAKE_EXTRA_FLAGS="-DCMAKE_INSTALL_PREFIX=$INSTALL_PREFIX"
    make install
    success "Neovim built and installed successfully."
}

update_path() {
    SHELL_CONFIG_FILE="$HOME/.bashrc"
    [ -n "$ZSH_VERSION" ] && SHELL_CONFIG_FILE="$HOME/.zshrc"

    if ! grep -q "export PATH=\"$INSTALL_PREFIX/bin:\$PATH\"" "$SHELL_CONFIG_FILE"; then
        log "Adding Neovim to PATH in $SHELL_CONFIG_FILE..."
        echo "export PATH=\"$INSTALL_PREFIX/bin:\$PATH\"" >> "$SHELL_CONFIG_FILE"
        success "Neovim added to PATH. Run 'source $SHELL_CONFIG_FILE' or restart your terminal to apply changes."
    else
        log "Neovim is already in the PATH."
    fi
}

main() {
    log "Starting Neovim installation script..."

    if $DRY_RUN; then
        log "Dry run enabled. No actions will be taken."
        log "Would create tools directory at $TOOLS_DIR."
        log "Would clone Neovim to $NEOVIM_DIR."
        log "Would build and install Neovim with prefix $INSTALL_PREFIX."
        log "Would add Neovim to PATH in shell configuration."
        exit 0
    fi

    mkdir -p "$TOOLS_DIR"
    check_dependencies
    clone_neovim
    build_and_install_neovim
    update_path

    success "Neovim installation completed successfully!"
}

# Check for dry run mode
if [ "$1" = "--dry-run" ]; then
    DRY_RUN=true
fi

main
