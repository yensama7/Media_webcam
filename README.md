# Phone Camera to Laptop Dashboard (Simple Guide)

This app lets you use your phone camera + microphone and watch it live on your laptop.

## Quick start (non-technical)

### Windows
- Double-click `run_dashboard.bat`
- It always runs in a persistent CMD window and keeps it open for troubleshooting.
- It will:
  1) check if npm exists,
  2) install Node.js LTS (includes npm) via `winget` if missing,
  3) run `npm install`,
  4) run `npm start`.

### Mac / Linux
- Double-click `run_dashboard.sh` (or run it from terminal)
- It keeps the window open when the script exits, so errors are visible.
- It will:
  1) check if npm exists,
  2) try to install Node.js/npm (apt/dnf/pacman/brew),
  3) run `npm install`,
  4) run `npm start`.

> Note: auto-install steps may ask for administrator password.

## Manual setup (if you prefer)
1. Open terminal in this folder.
2. Run:
   ```bash
   npm install
   npm start
   ```

Then open dashboard on laptop:
- `http://localhost:8080/`

## Connect your phone
1. On dashboard, copy one of the shown phone links.
2. Open that link on your phone browser.
3. Hold the phone in landscape while filming.
4. Allow camera + microphone permissions.

The feed should appear automatically on dashboard without refreshing.


## Connection limits and reconnect behavior
- Maximum connected phones: **5** (extra phones are rejected to protect network stability).
- If a feed drops, dashboard retries reconnect for up to **60 seconds**.
- During retry, a branded AFIT placeholder panel is shown in that card.
- If reconnect fails after 60 seconds, the card is removed automatically.

## Audio controls
- Click **Unmute** on a camera card to hear phone audio.
- Hold **Hold to Talk to All Phones** to broadcast dashboard mic to all phones.
- Hold **Hold to Talk** on one card to talk only to that phone.

## Dashboard enhancement
- Leave **Enhance dashboard video (local only)** enabled for slightly better-looking video.
- This enhancement is local display processing only, so it does not increase network bitrate.
- Dashboard cards are shown in landscape (16:9), similar to Iriun framing.

## OBS integration (script)
Use the included OBS Lua script (`obs_dashboard_source.lua`) to add an OBS-only clean video feed (no dashboard controls/UI).

### Steps
1. Start this app (`run_dashboard.bat` or `run_dashboard.sh`).
2. Open OBS.
3. Go to **Tools -> Scripts**.
4. Click **+** and choose `obs_dashboard_source.lua`.
5. Configure:
   - `Device index` (0 = first phone, 1 = second, etc.)
   - `Auto-cycle devices` (on/off)
   - `Cycle interval (ms)` if auto-cycle is on
6. Click **Create / Update Browser Source**.

OBS uses `http://127.0.0.1:8080/obs` with query params for index/cycling.

## If feed is laggy
- Keep both devices on strong Wi-Fi (5GHz preferred).
- Move phone and laptop closer to router.
- Close heavy downloads/streams on same network.
- Keep laptop plugged in (avoid power-saving throttling).

## If it doesn't connect
- Make sure both devices are on the same Wi-Fi.
- Allow port `8080` in laptop firewall.
- Refresh dashboard and phone pages.
- Restart app.
