@echo off
setlocal EnableDelayedExpansion

cd /d "%~dp0"

echo [INFO] Starting Media_webcam launcher...

echo [INFO] Checking if npm is installed...
where npm >nul 2>nul
if %ERRORLEVEL% neq 0 (
  echo [WARN] npm not found. Attempting to install Node.js LTS via winget...

  where winget >nul 2>nul
  if %ERRORLEVEL% neq 0 (
    echo [ERROR] winget is not available on this system.
    echo [ERROR] Install Node.js LTS from https://nodejs.org and run this file again.
    goto :end_with_pause
  )

  winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
  if %ERRORLEVEL% neq 0 (
    echo [ERROR] Failed to install Node.js automatically.
    echo [ERROR] Install Node.js manually from https://nodejs.org and run this file again.
    goto :end_with_pause
  )
)

echo [INFO] Node version:
node -v
if %ERRORLEVEL% neq 0 (
  echo [ERROR] Node is still not available on PATH.
  goto :end_with_pause
)

echo [INFO] npm version:
npm -v
if %ERRORLEVEL% neq 0 (
  echo [ERROR] npm is still not available on PATH.
  goto :end_with_pause
)

echo [INFO] Installing project dependencies...
call npm install
if %ERRORLEVEL% neq 0 (
  echo [ERROR] npm install failed.
  goto :end_with_pause
)

echo [INFO] Starting project server...
echo [INFO] Keep this window open. It will show dashboard and phone links.
call npm start
if %ERRORLEVEL% neq 0 (
  echo [ERROR] npm start exited with an error.
)

:end_with_pause
echo.
echo [INFO] Press any key to close this window.
pause >nul
endlocal
