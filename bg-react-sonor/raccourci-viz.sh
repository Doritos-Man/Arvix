#!/usr/bin/env bash

# --- Configuration ---
PIDFILE="/tmp/audio_visualizer.pid"
SCRIPT_PATH="$HOME/Arvix/bg-react-sonor/audio-script.sh"
WORKDIR="$HOME/Arvix/bg-react-sonor"

# Si le script est déjà lancé
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    MAIN_PID=$(cat "$PIDFILE")
    kill "$MAIN_PID" 2>/dev/null
    rm -f "$PIDFILE"
    killall conky
    notify-send "Visualizer" "⛔ Arrêté"
    exit 0
fi

# Sinon → START
cd "$WORKDIR" || exit 1
killall conky
kill audio-script.sh
nohup ./audio-script.sh >/dev/null 2>&1 &
echo $! > "$PIDFILE"

notify-send "Visualizer" "🎵 Démarré"
