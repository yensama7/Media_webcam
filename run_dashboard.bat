@echo off
setlocal

REM Always run in a persistent cmd session.
if /I "%~1" neq "_inner" (
  cmd /k ""%~f0" _inner"
  exit /b
)

cd /d "%~dp0"

echo [INFO] Starting Media_webcam launcher...

echo [STEP 1/3] Checking if npm is installed...
where npm >nul 2>nul
if %ERRORLEVEL% neq 0 (
  echo [WARN] npm not found.
  echo [STEP 2/3] Attempting to install Node.js LTS ^(includes npm^) via winget...

  where winget >nul 2>nul
  if %ERRORLEVEL% neq 0 (
    echo [ERROR] winget is not available.
    echo [ERROR] Please install Node.js LTS manually: https://nodejs.org
    goto :end_with_pause
  )

  winget install OpenJS.NodeJS.LTS --accept-package-agreements --accept-source-agreements
  if %ERRORLEVEL% neq 0 (
    echo [ERROR] Automatic install failed.
    echo [ERROR] Please install Node.js LTS manually: https://nodejs.org
    goto :end_with_pause
  )

  echo [INFO] Re-checking npm after installation...
  where npm >nul 2>nul
  if %ERRORLEVEL% neq 0 (
    echo [ERROR] npm still not found in this session.
    echo [ERROR] Close and reopen this script after Node installation completes.
    goto :end_with_pause
  )
)

echo [INFO] Node version:
node -v
if %ERRORLEVEL% neq 0 (
  echo [ERROR] node command failed.
  goto :end_with_pause
)

echo [INFO] npm version:
npm -v
if %ERRORLEVEL% neq 0 (
  echo [ERROR] npm command failed.
  goto :end_with_pause
)

echo [INFO] Installing project dependencies...
call npm install
if %ERRORLEVEL% neq 0 (
  echo [ERROR] npm install failed.
  goto :end_with_pause
)

echo [STEP 3/3] Running npm start...
echo [INFO] Keep this window open. It will print the dashboard/phone links.
call npm start
if %ERRORLEVEL% neq 0 (
  echo [ERROR] npm start exited with an error.
)

:end_with_pause
echo.
echo [INFO] Window stays open for troubleshooting.
pause
endlocal
