#!/usr/bin/env bash
# audio-script.sh — Version corrigée : Détection par flux d'applications

# --- Fonctions utilitaires ---
function cleanup {
    echo "🛑 Arrêt Visualizer : "
    
    # Tuer le lanceur et le script python
    pkill -f run_visualizer.sh 2>/dev/null
    pkill -f cava_ws.py 2>/dev/null
    
    # Tuer le serveur HTTP et Cava
    fuser -k 8000/tcp 2>/dev/null
    killall cava 2>/dev/null

    fuser -k 8765/tcp 2>/dev/null 
    fuser -k 8000/tcp 2>/dev/null

    rm -f /tmp/cava.fifo
    # 3. Attendre que le port 8765 soit vraiment libre

    while lsof -i:8765 -t >/dev/null 2>&1; do
        echo "⏳ Attente libération du port 8765..."
        sleep 0.2
    done
    while lsof -i:8000 -t >/dev/null 2>&1; do
        echo "⏳ Attente libération du port 8000..."
        sleep 0.2
    done


    echo "✅ Visualizer arrêté"
}

function launch_visualizer {

    if [ -f ~/visualizer-env/bin/activate ]; then
        source ~/visualizer-env/bin/activate
    else
        echo "❌ Environnement Python non trouvé"
        cd ~
        python3 -m venv visualizer-env
        source ~/visualizer-env/bin/activate
        pip install --upgrade pip
        pip install websockets numpy asyncio
        echo "Environnement Créé ? Veuillez réexécuter le script."
        cd ~/Arvix/bg-react-sonor
        exit 1
    fi

    if [ -f ./run_visualizer.sh ]; then
        echo "🚀 Lancement visualizer..."
        ./run_visualizer.sh &
    fi
}

function cleanup_hidamari {
    echo "🛑 Arrêt Hidamari : "
    flatpak kill io.github.jeffshee.Hidamari 2>/dev/null
    echo "✅ Hidamari arrêté"
}

function launch_hidamari {
    echo "🌻 Lancement de Hidamari..."
    cp ~/Arvix/bg-react-sonor/hidamari_config.json ~/.var/app/io.github.jeffshee.Hidamari/config/hidamari/config.json
    flatpak run io.github.jeffshee.Hidamari -b &
}

function handle_exit {
    echo -e "\n🛑 Interruption détectée ! Arrêt des processus..."
    cleanup
    cleanup_hidamari
    exit 0
}

# --- Variables ---
VISUALIZER_RUNNING=false
HIDAMARI_RUNNING=false
LAST_STATE="STOPPED"


# --- Programme ---
trap handle_exit SIGINT SIGTERM #En cas d'interruption

echo "🎵 Demarrage du script de fond d'écran audio-reactif. 🎵"
cd ~/Arvix/bg-react-sonor || { echo "❌ Répertoire introuvable"; exit 1; }
echo "🧹 Nettoyage préliminaire.."
cleanup
cleanup_hidamari
sleep 1

# --- Boucle principale ---
while true; do
    # 1. On compte combien d'applications jouent VRAIMENT (State: RUNNING)
    # On ignore 'corked' (pause) et 'suspended'.
    ACTIVE_STREAMS=$(LANG=C pactl list sink-inputs | grep -c "Corked: no")

    # 2. Si aucun flux actif (0 applications qui jouent)
    if [ "$ACTIVE_STREAMS" -eq 0 ]; then
        echo "🔎 Aucune musique détéctée..."
        if [ "$LAST_STATE" == "PLAYING" ]; then          
            # Arrêt Hidamari
            if [ "$HIDAMARI_RUNNING" = true ]; then
                cleanup_hidamari
                HIDAMARI_RUNNING=false
            fi

            # Arrêt Visualizer
            if [ "$VISUALIZER_RUNNING" = true ]; then
                cleanup
                VISUALIZER_RUNNING=false
            fi
            
            LAST_STATE="STOPPED"
        fi

    # 3. Si au moins 1 application joue
    else
        # Si on n'était pas déjà en train de jouer
        if [ "$LAST_STATE" == "STOPPED" ]; then
            echo "▶️  Musique détectée, Lancement du processus..."

            # Arrêt Hidamari
            if [ "$HIDAMARI_RUNNING" = true ]; then
                cleanup_hidamari
                HIDAMARI_RUNNING=false
            fi

            # Arrêt Visualizer
            if [ "$VISUALIZER_RUNNING" = true ]; then
                cleanup
                VISUALIZER_RUNNING=false
            fi

            # Lancement séquentiel
            launch_visualizer
            VISUALIZER_RUNNING=true

            echo "Démarrage de l'affichage dans 6 secondes..."
            sleep  6 # Temps pour que le serveur HTTP démarre
            
            launch_hidamari
            HIDAMARI_RUNNING=true
            
            LAST_STATE="PLAYING"
        fi
    fi

    sleep 3
done