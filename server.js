const http = require("http");
const fs = require("fs");
const os = require("os");
const WebSocket = require("ws");
const { randomUUID } = require("crypto");

function sendJson(ws, payload) {
  if (ws && ws.readyState === WebSocket.OPEN) {
    ws.send(JSON.stringify(payload));
  }
}

function getLanIps() {
  const interfaces = os.networkInterfaces();
  const ips = [];

  Object.values(interfaces).forEach((items) => {
    (items || []).forEach((item) => {
      if (item.family === "IPv4" && !item.internal) {
        ips.push(item.address);
      }
    });
  });

  return [...new Set(ips)];
}

const server = http.createServer((req, res) => {
  if (req.url === "/phone") {
    res.writeHead(200, { "Content-Type": "text/html" });
    res.end(fs.readFileSync("phone.html"));
    return;
  }

  if (req.url === "/" || req.url === "/dashboard") {
    res.writeHead(200, { "Content-Type": "text/html" });
    res.end(fs.readFileSync("dashboard.html"));
    return;
  }

  if (req.url === "/api/server-info") {
    const payload = {
      ips: getLanIps(),
      port: 8080
    };
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify(payload));
    return;
  }

  res.writeHead(404);
  res.end("Page not found. Try /phone or /dashboard");
});

const wss = new WebSocket.Server({ server });

console.log("📡 Server starting...");

const socketsById = new Map();
const devicesBySocketId = new Map();
const dashboards = new Set();

wss.on("connection", (ws) => {
  const socketId = randomUUID();
  socketsById.set(socketId, ws);

  ws.on("message", (rawData) => {
    try {
      const msg = JSON.parse(rawData);

      if (msg.type === "register") {
        devicesBySocketId.set(socketId, {
          socketId,
          deviceId: msg.id,
          name: msg.name
        });
        console.log(`📱 Device connected: ${msg.name}`);
        broadcastDeviceList();
        return;
      }

      if (msg.type === "dashboard") {
        dashboards.add(socketId);
        broadcastDeviceList();
        return;
      }

      if (msg.type === "watch") {
        const target = findDeviceSocketByDeviceId(msg.deviceId);
        sendJson(target, {
          type: "watch",
          from: socketId
        });
        return;
      }

      if (msg.type === "signal") {
        const target = socketsById.get(msg.to);
        sendJson(target, {
          type: "signal",
          from: socketId,
          data: msg.data,
          deviceId: msg.deviceId || null
        });
        return;
      }
    } catch (error) {
      console.error("Bad message", error);
    }
  });

  ws.on("close", () => {
    const device = devicesBySocketId.get(socketId);
    if (device) {
      devicesBySocketId.delete(socketId);
      console.log(`❌ Device disconnected: ${device.name}`);
      broadcastDeviceList();
    }

    dashboards.delete(socketId);
    socketsById.delete(socketId);
  });
});

function findDeviceSocketByDeviceId(deviceId) {
  for (const [socketId, device] of devicesBySocketId.entries()) {
    if (device.deviceId === deviceId) {
      return socketsById.get(socketId);
    }
  }
  return null;
}

function broadcastDeviceList() {
  const list = Array.from(devicesBySocketId.values()).map((device) => ({
    id: device.deviceId,
    name: device.name
  }));

  dashboards.forEach((dashboardSocketId) => {
    const dashboardSocket = socketsById.get(dashboardSocketId);
    sendJson(dashboardSocket, { type: "devices", devices: list });
  });
}

server.listen(8080, "0.0.0.0", () => {
  console.log("✅ Web & WebSocket Server running!");
  console.log("➡️  Dashboard: http://localhost:8080/");
  console.log("➡️  Phone: http://localhost:8080/phone");
  console.log(`➡️  LAN IP(s): ${getLanIps().join(", ") || "Not detected"}`);
});
