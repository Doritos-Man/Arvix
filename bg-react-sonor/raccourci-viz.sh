#!/usr/bin/env bash

PIDFILE="/tmp/audio_visualizer.pid"

# Si déjà lancé → STOP
if [ -f "$PIDFILE" ] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    kill "$(cat "$PIDFILE")"
    flatpak kill io.github.jeffshee.Hidamari 2>/dev/null
    rm -f "$PIDFILE"
    notify-send "Visualizer" "⛔ Arrêté"
    exit 0
fi

# Sinon → START
cd "$HOME/Arvix/bg-react-sonor" || exit 1
nohup ./audio-script.sh >/dev/null 2>&1 &
echo $! > "$PIDFILE"

notify-send "Visualizer" "🎵 Démarré"
