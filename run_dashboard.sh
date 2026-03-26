#!/usr/bin/env bash
set -euo pipefail

# 1. Set the working directory to the script's location
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

pause_before_exit() {
  if [[ -t 0 && -t 1 && "${NO_PAUSE:-0}" != "1" ]]; then
    echo
    read -r -p "[INFO] Press Enter to close this window..." _
  fi
}

trap pause_before_exit EXIT

echo "[INFO] Starting Media_webcam launcher..."
echo "[STEP 1] Checking if npm is installed..."

auto_install_node() {
  echo "[WARN] npm is not installed."
  echo "[STEP 2] Attempting to auto-install Node.js and npm..."

  local INSTALLED=0

  if command -v apt-get >/dev/null 2>&1; then
    echo "[INFO] Installing Node.js + npm using apt-get..."
    sudo apt-get update
    sudo apt-get install -y nodejs npm
    INSTALLED=1
  elif command -v dnf >/dev/null 2>&1; then
    echo "[INFO] Installing Node.js + npm using dnf..."
    sudo dnf install -y nodejs npm
    INSTALLED=1
  elif command -v pacman >/dev/null 2>&1; then
    echo "[INFO] Installing Node.js + npm using pacman..."
    sudo pacman -Sy --noconfirm nodejs npm
    INSTALLED=1
  elif command -v brew >/dev/null 2>&1; then
    echo "[INFO] Installing Node.js (includes npm) using Homebrew..."
    brew install node
    INSTALLED=1
  else
    echo "[ERROR] No supported package manager found."
    echo "[ERROR] Please install Node.js LTS manually from https://nodejs.org and run this script again."
    exit 1
  fi

  # THE RESTART LOGIC
  if [ $INSTALLED -eq 1 ]; then
    echo "[SUCCESS] Installation complete."
    echo "[INFO] Restarting script to refresh environment variables..."
    
    # Clear the command hash cache just to be safe
    hash -r 2>/dev/null || true
    
    # This command replaces the current script process with a fresh run of this exact file
    exec "$0" "$@"
  fi
}

# 2. Check for npm. If missing, run the installer.
if ! command -v npm >/dev/null 2>&1; then
  auto_install_node
else
  echo "[SUCCESS] npm is already installed! Skipping installation."
fi

# 3. RUN APP SECTION
echo ""
echo "[INFO] Node version: $(node -v 2>/dev/null || echo 'not found')"
echo "[INFO] npm version: $(npm -v 2>/dev/null || echo 'not found')"

echo "[INFO] Checking project dependencies..."
npm install

echo "[STEP 3] Starting project server..."
echo "[INFO] Keep this window open. It will show your dashboard and phone links."
npm start
