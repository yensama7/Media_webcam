@echo off
setlocal

REM Always run in a persistent cmd session.
if /I "%~1" neq "_inner" (
  cmd /k ""%~f0" _inner"
  exit /b
)

cd /d "%~dp0"

echo [INFO] Starting Media_webcam launcher...
echo [STEP 1] Checking if npm is installed...

REM Check if npm exists on the system
where npm >nul 2>nul

REM If ERRORLEVEL is 0, npm is installed. Jump straight to running the app.
if %ERRORLEVEL% equ 0 (
    echo [SUCCESS] npm is already installed! Skipping installation.
    goto :start_app
)

REM --- INSTALLATION SECTION (Only runs if npm was NOT found) ---
echo [WARN] npm not found.
echo [STEP 2] Attempting to install Node.js LTS (includes npm) via winget...

where winget >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] winget is not available. Please install Node.js manually: https://nodejs.org
    goto :end_with_pause
)

winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
if %ERRORLEVEL% neq 0 (
    echo [ERROR] Automatic install failed. Please install Node.js manually: https://nodejs.org
    goto :end_with_pause
)

echo [SUCCESS] Node.js installation complete.
echo [INFO] Restarting this window so the system recognizes the new npm command...
start cmd /k "cd /d "%~dp0" && "%~f0""
exit /b


REM --- RUN APP SECTION (Jumps here if npm is already installed) ---
:start_app
echo.
echo [INFO] Node version:
node -v
echo [INFO] npm version:
call npm -v

echo [INFO] Checking project dependencies...
call npm install
if %ERRORLEVEL% neq 0 (
    echo [ERROR] npm install failed.
    goto :end_with_pause
)

echo [STEP 3] Running npm start...
echo [INFO] Keep this window open. It will print your dashboard and phone links.
call npm start
if %ERRORLEVEL% neq 0 (
    echo [ERROR] npm start exited with an error.
)

:end_with_pause
echo.
echo [INFO] Window stays open for troubleshooting.
pause
endlocal
