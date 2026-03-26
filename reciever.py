import asyncio
import json
import cv2
import websockets
from aiortc import RTCPeerConnection, RTCSessionDescription
from aiortc.contrib.media import MediaBlackhole

pc = RTCPeerConnection()

@pc.on("track")
def on_track(track):
    print("Track received:", track.kind)

    if track.kind == "video":
        asyncio.create_task(display_video(track))

async def display_video(track):
    while True:
        frame = await track.recv()
        img = frame.to_ndarray(format="bgr24")
        cv2.imshow("Church Camera", img)
        cv2.waitKey(1)

async def main():
    async with websockets.connect("ws://localhost:8080") as ws:
        while True:
            message = json.loads(await ws.recv())

            if message["type"] == "offer":
                offer = RTCSessionDescription(**message["data"])
                await pc.setRemoteDescription(offer)

                answer = await pc.createAnswer()
                await pc.setLocalDescription(answer)

                await ws.send(json.dumps({
                    "type": "answer",
                    "data": {
                        "sdp": pc.localDescription.sdp,
                        "type": pc.localDescription.type
                    }
                }))

            elif message["type"] == "candidate":
                await pc.addIceCandidate(message["data"])

asyncio.run(main())