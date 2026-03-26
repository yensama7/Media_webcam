const http = require("http");
const fs = require("fs");
const WebSocket = require("ws");

// 1. Create a basic web server to serve the HTML files
const server = http.createServer((req, res) => {
  if (req.url === "/phone") {
    res.writeHead(200, { "Content-Type": "text/html" });
    res.end(fs.readFileSync("phone.html"));
  } else if (req.url === "/" || req.url === "/dashboard") {
    res.writeHead(200, { "Content-Type": "text/html" });
    res.end(fs.readFileSync("dashboard.html"));
  } else {
    res.writeHead(404);
    res.end("Page not found. Try /phone or /dashboard");
  }
});

// 2. Attach your WebSocket server to the same port
const wss = new WebSocket.Server({ server });

console.log("📡 Server starting...");

let devices = new Map();
let dashboards = new Set();

wss.on("connection", (ws) => {
  ws.on("message", (data) => {
    try {
      const msg = JSON.parse(data);

      if (msg.type === "register") {
        devices.set(ws, { id: msg.id, name: msg.name, lastFrame: null });
        console.log(`📱 Device connected: ${msg.name}`);
        broadcastDeviceList();
        return;
      }

      if (msg.type === "frame") {
        const device = devices.get(ws);
        if (!device) return;
        device.lastFrame = msg.data;

        dashboards.forEach(d => {
          if (d.readyState === 1) {
            d.send(JSON.stringify({ type: "frame", id: device.id, data: msg.data }));
          }
        });
        return;
      }

      if (msg.type === "dashboard") {
        dashboards.add(ws);
        broadcastDeviceList();
        return;
      }
    } catch (e) {
      console.error("Bad message", e);
    }
  });

  ws.on("close", () => {
    if (devices.has(ws)) {
      const name = devices.get(ws).name;
      devices.delete(ws);
      console.log(`❌ Device disconnected: ${name}`);
      broadcastDeviceList();
    }
    dashboards.delete(ws);
  });
});

function broadcastDeviceList() {
  const list = Array.from(devices.values()).map(d => ({ id: d.id, name: d.name }));
  dashboards.forEach(d => {
    if (d.readyState === 1) {
      d.send(JSON.stringify({ type: "devices", devices: list }));
    }
  });
}

// 3. Listen on port 8080
server.listen(8080, "0.0.0.0", () => {
  console.log("✅ Web & WebSocket Server running!");
  console.log("➡️  Dashboard: http://localhost:8080/");
});