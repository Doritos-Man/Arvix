#!/usr/bin/env bash
# run_visualizer.sh — Lance Cava + WebSocket + serveur HTTP

FIFO="/tmp/cava.fifo"
HTTP_PORT=8000

# --- Créer FIFO si nécessaire ---
if [ ! -p "$FIFO" ]; then
    echo "📦 Création FIFO $FIFO"
    mkfifo "$FIFO"
fi

# --- Lancer Cava ---
echo "▶ Lancement Cava..."
cava & > /dev/null 2>&1

# --- Lancer le WebSocket Python ---
echo "▶ Lancement WebSocket..."
python3 ~/Arvix/bg-react-sonor/cava_ws.py &

sleep 1

# --- Lancer le serveur HTTP ---
echo "▶ Lancement serveur HTTP ..."
python3 -m http.server "$HTTP_PORT" &
sleep 1
# --- Attente indéfinie pour garder le script actif ---

wait
