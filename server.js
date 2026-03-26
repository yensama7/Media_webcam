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

function isLikelyLanInterface(name) {
  const lowered = name.toLowerCase();
  const blocked = ["docker", "veth", "br-", "virbr", "vmnet", "vbox", "tailscale", "utun", "tun", "tap"];
  return !blocked.some((fragment) => lowered.includes(fragment));
}

function isPrivateIpv4(ip) {
  return ip.startsWith("10.") || ip.startsWith("192.168.") || /^172\.(1[6-9]|2\d|3[0-1])\./.test(ip);
}

function getLanIps() {
  const interfaces = os.networkInterfaces();
  const ips = [];

  Object.entries(interfaces).forEach(([name, items]) => {
    if (!isLikelyLanInterface(name)) return;

    (items || []).forEach((item) => {
      if (item.family === "IPv4" && !item.internal && isPrivateIpv4(item.address)) {
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

  if (req.url === "/obs") {
    res.writeHead(200, { "Content-Type": "text/html" });
    res.end(fs.readFileSync("obs.html"));
    return;
  }

  if (req.url === "/api/devices") {
    const list = Array.from(devicesBySocketId.values()).map((device) => ({
      id: device.deviceId,
      name: device.name
    }));
    res.writeHead(200, { "Content-Type": "application/json" });
    res.end(JSON.stringify({ devices: list }));
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

      if (msg.type === "talk") {
        if (msg.target === "all") {
          devicesBySocketId.forEach((device) => {
            const target = socketsById.get(device.socketId);
            sendJson(target, { type: "talk", mimeType: msg.mimeType, data: msg.data });
          });
          return;
        }

        const target = findDeviceSocketByDeviceId(msg.target);
        sendJson(target, { type: "talk", mimeType: msg.mimeType, data: msg.data });
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
