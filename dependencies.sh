#!/bin/bash

# Function to install Homebrew
install_homebrew() {
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

# Function to check if a package is installed
is_installed() {
    if command -v "$1" &>/dev/null; then
        echo "$1 is already installed."
        return 0
    else
        return 1
    fi
}

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    install_homebrew
else
    echo "Homebrew is already installed."
fi

# List of dependencies to install via Homebrew
dependencies=(
    "cmake"
    "neovim"
    "ripgrep"
    "llvm"
)

# Install each dependency if it's not already installed
for package in "${dependencies[@]}"; do
    if ! is_installed "$package"; then
        echo "$package not found. Installing..."
        brew install "$package"
    fi
done

echo "All dependencies checked and installed if needed!"

