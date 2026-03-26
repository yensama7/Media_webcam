#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo "[INFO] Starting Media_webcam launcher..."

auto_install_node() {
  if command -v apt-get >/dev/null 2>&1; then
    echo "[INFO] Installing Node.js + npm using apt-get..."
    sudo apt-get update
    sudo apt-get install -y nodejs npm
    return
  fi

  if command -v dnf >/dev/null 2>&1; then
    echo "[INFO] Installing Node.js + npm using dnf..."
    sudo dnf install -y nodejs npm
    return
  fi

  if command -v pacman >/dev/null 2>&1; then
    echo "[INFO] Installing Node.js + npm using pacman..."
    sudo pacman -Sy --noconfirm nodejs npm
    return
  fi

  if command -v brew >/dev/null 2>&1; then
    echo "[INFO] Installing Node.js (includes npm) using Homebrew..."
    brew install node
    return
  fi

  echo "[ERROR] No supported package manager found."
  echo "[ERROR] Please install Node.js LTS from https://nodejs.org and run this script again."
  exit 1
}

if ! command -v npm >/dev/null 2>&1; then
  echo "[WARN] npm is not installed."
  auto_install_node
fi

echo "[INFO] Node version: $(node -v 2>/dev/null || echo 'not found')"
echo "[INFO] npm version: $(npm -v)"

echo "[INFO] Installing project dependencies..."
npm install

echo "[INFO] Launching server with npm start..."
npm start
