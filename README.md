# Phone Camera to Laptop Dashboard (Simple Guide)

This app lets you use your phone camera + microphone and watch it live on your laptop.

## What you need
- A laptop and a phone on the **same Wi-Fi**.
- Node.js installed on the laptop.

## One-time setup (laptop)
1. Open a terminal in this folder.
2. Run:
   ```bash
   npm install
   ```

## Start the app (laptop)
Run:
```bash
npm start
```

Then open this on your laptop browser:
- `http://localhost:8080/`

## Connect your phone
1. On dashboard, find: **"On your phone browser, open one of these links"**.
2. Pick one shown link (for example `http://192.168.1.10:8080/phone`).
3. Open it on your phone browser.
4. Allow camera + microphone permissions.

The feed should appear automatically on dashboard without refreshing.

## Audio
- Each camera card starts muted on dashboard.
- Click **Unmute** to hear that phone.

## Talk back from dashboard (walkie-talkie style)
- **Hold to Talk to All Phones**: press and hold to broadcast your laptop microphone to every phone.
- **Hold to Talk** (inside a camera card): press and hold to talk to that phone only.
- When you release the button, talking stops.

## Phone connection quality badge
- Top-right of phone screen shows connection quality and latency (`ms`).
- Colors:
  - Green = Good
  - Yellow = Medium
  - Red = Poor

## Why might multiple IPs show?
- Some laptops have extra virtual adapters (VPN, Docker, etc.).
- The app now filters to likely private LAN IPs to reduce wrong entries.
- If more than one still appears, use the one that opens `/phone` on your phone.

## If feed is laggy
- Keep both devices on strong Wi-Fi (5GHz if available).
- Stay closer to the router.
- Close heavy downloads or streaming on the same network.
- Keep the laptop plugged in (power-save modes can add delay).

## If it doesn't connect
- Make sure both devices are on the same Wi-Fi.
- Allow port `8080` in laptop firewall.
- Refresh dashboard and phone pages.
- Restart server (`Ctrl + C`, then `npm start`).
