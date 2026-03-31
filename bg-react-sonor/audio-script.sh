#!/usr/bin/env bash

# --- Variables de chemins ---
PATH_ARVIX="$HOME/Arvix/bg-react-sonor"
FIFO_ARVIX="/dev/shm/cava.fifo" # Nom unique pour éviter les conflits
PID_FILE="/dev/shm/arvix_pids"

function cleanup {
    echo "🧹 Arrêt ciblé du visualizer..."
    # On ne tue que les PIDs enregistrés pour ne pas toucher à l'extension
    if [ -f "$PID_FILE" ]; then
        while read -r pid; do
            kill "$pid" 2>/dev/null
        done < "$PID_FILE"
        killall conky
        rm "$PID_FILE"
    fi
    # Sécurité au cas où, mais on évite killall
    rm -f "$FIFO_ARVIX"
}

function launch_visualizer {
    echo "🚀 Lancement visualizer"
    [ ! -p "$FIFO_ARVIX" ] && mkfifo "$FIFO_ARVIX"

    # 1. On lance Cava avec son propre config SANS copier dans ~/.config
    # On capture son PID ($!)
    cava -p "$PATH_ARVIX/cava.config" & 
    echo $! > "$PID_FILE"

    sleep 2.5

    # 2. On lance Conky et on capture aussi son PID
    conky -c "$PATH_ARVIX/arvix.conkyrc" &
    echo $! >> "$PID_FILE"
}

function handle_exit {
    echo -e "\n🛑 Interruption détectée ! Arrêt des processus..."
    cleanup
    exit 0
}

# --- Variables ---
VISUALIZER_RUNNING=false
LAST_STATE="STOPPED"

# --- Programme ---
trap handle_exit SIGINT SIGTERM

echo "🎵 Demarrage du script de fond d'écran audio-reactif. 🎵"
cd ~/Arvix/bg-react-sonor || { echo "❌ Répertoire introuvable"; exit 1; }

echo "🧹 Nettoyage préliminaire..."
cleanup
sleep 2

# --- Boucle principale ---
while true; do
    # Compter les flux audio actifs (non suspendus, non en pause)
    ACTIVE_STREAMS=$(LANG=C pactl list sink-inputs | grep -c "Corked: no")

    # 2. Si aucun flux actif (0 applications qui jouent)
    if [ "$ACTIVE_STREAMS" -eq 0 ]; then
        echo "🔎 Aucune musique détéctée..."
        if [ "$LAST_STATE" == "PLAYING" ]; then          
            # Arrêt Visualizer
            if [ "$VISUALIZER_RUNNING" = true ]; then
                cleanup
                VISUALIZER_RUNNING=false
                LAST_STATE="STOPPED"
            fi    
        fi


    else
        # Au moins une application joue
        if [ "$LAST_STATE" == "STOPPED" ]; then
            echo "🎵 Musique détectée, lancement du visualizer..."
            launch_visualizer
            VISUALIZER_RUNNING=true
            LAST_STATE="PLAYING"
        fi
    fi

    sleep 5
done
