import asyncio
import os
import signal
import websockets
from websockets.exceptions import ConnectionClosed

FIFO = "/tmp/cava.fifo"
FPS = 60
latest = "0;" * 64

async def read_cava():
    global latest
    loop = asyncio.get_event_loop()

    if not os.path.exists(FIFO):
        os.mkfifo(FIFO)

    print("🎧 Lecture Cava...")
    
    try:
        # On utilise run_in_executor pour ne pas bloquer la loop
        with open(FIFO, "r") as f:
            while True:
                line = await loop.run_in_executor(None, f.readline)
                if line:
                    latest = line.strip()
                else:
                    await asyncio.sleep(0.01)
    except Exception as e:
        print(f"⚠️ Erreur lecture FIFO: {e}")

async def ws_handler(ws):
    print("🌐 Client connecté")
    try:
        while True:
            await ws.send(latest)
            await asyncio.sleep(1 / FPS)
    except (ConnectionClosed, asyncio.CancelledError):
        print("🌐 Client déconnecté (ou arrêt demandé)")
    except Exception as e:
        print(f"❌ Erreur WebSocket: {e}")

async def main():
    # Gestion propre de l'arrêt (SIGTERM/SIGINT)
    loop = asyncio.get_running_loop()
    stop_event = asyncio.Event()

    def signal_handler():
        stop_event.set()

    for sig in (signal.SIGINT, signal.SIGTERM):
        loop.add_signal_handler(sig, signal_handler)

    # Tâche de lecture Cava
    cava_task = asyncio.create_task(read_cava())

    # Serveur WebSocket
    async with websockets.serve(ws_handler, "127.0.0.1", 8765, reuse_address=True):
        print("✅ WebSocket prêt sur ws://localhost:8765")
        await stop_event.wait()

    
    cava_task.cancel()
    print("🧹 Fermeture cava_ws.py.")

if __name__ == "__main__":
    asyncio.run(main())