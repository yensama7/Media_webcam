@echo off
setlocal

cd /d "%~dp0"

echo [INFO] Starting Media_webcam launcher...

where npm >nul 2>nul
if %ERRORLEVEL% neq 0 (
  echo [WARN] npm not found. Attempting to install Node.js LTS via winget...
  where winget >nul 2>nul
  if %ERRORLEVEL% neq 0 (
    echo [ERROR] winget is not available on this system.
    echo [ERROR] Please install Node.js LTS from https://nodejs.org and run this file again.
    pause
    exit /b 1
  )

  winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
  if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to install Node.js automatically.
    echo [ERROR] Please install Node.js manually from https://nodejs.org.
    pause
    exit /b 1
  )
)

echo [INFO] Node version:
node -v

echo [INFO] npm version:
npm -v

echo [INFO] Installing project dependencies...
call npm install
if %ERRORLEVEL% neq 0 (
  echo [ERROR] npm install failed.
  pause
  exit /b 1
)

echo [INFO] Launching server with npm start...
call npm start

endlocal
