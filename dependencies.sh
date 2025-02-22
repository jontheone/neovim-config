#!/bin/bash

# Function to install Homebrew
install_homebrew() {
    echo "Homebrew not found. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> ~/.bashrc
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
}

# Check if Homebrew is installed
if ! command -v brew &>/dev/null; then
    install_homebrew
else
    echo "Homebrew is already installed."
fi

# List of dependencies to install via Homebrew
dependencies=(
    "ripgrep"
    "neovim"
    "fzf"
)

# Install each dependency
for package in "${dependencies[@]}"; do
    brew install "$package"
done

echo "All dependencies installed!"

