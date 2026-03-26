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

After starting, open this on your laptop browser:
- `http://localhost:8080/`

This is the **Dashboard** page.

## Connect your phone (easy)
1. On the dashboard page, look for the section that says:
   - "On your phone browser, open one of these links"
2. It shows your laptop IP link, for example:
   - `http://192.168.1.10:8080/phone`
3. Type that exact link in your phone browser.
4. Allow camera and microphone permissions.

Done — your phone camera should appear on the laptop dashboard.

## Audio
- Every camera card starts muted.
- Click **Unmute** on a card to hear sound.

## Connection quality indicator on phone
- On the top-right corner of the phone page, you will see live connection quality.
- Colors:
  - **Green** = good
  - **Yellow** = medium
  - **Red** = poor
- The number shown is round-trip latency in milliseconds (`ms`). Lower is better.

## If it doesn't connect
- Make sure both devices are on the same Wi-Fi.
- Make sure laptop firewall allows port `8080`.
- Refresh both pages.
- Restart server with `Ctrl + C` then `npm start` again.

## Quick restart
```bash
npm start
```
