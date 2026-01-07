# 📍 Feuille de Route - Projet Arvix

### Explications

  Cette Feuille de Route suit le l'installation chronologique d'ArviX (Assistant de Routines Virtuelles Intelligent) sur une machine linux Ubuntu 24.04 en dual Boot avec Windows 10. Puis la configuration personnalisée de l'interface graphique avec Hyprland et l'integration d'un assistant IA capable d'intéragir avec le système. 

## Étape 1 : Installation Ubuntu

- [X] Partition du disque.

  Si vous partez de zero, sans linux installé utilisez d'abord le [Gestionnaire de disque Windows](https://support.microsoft.com/fr-fr/windows/gestion-des-disques-dans-windows-ad88ba19-f0d3-0809-7889-830f63e94405) pour liberer l'espace néssessaire au nouveau système d'exploitation (je prends 100Gio - c'est largement suffisant pour notre utilisation). Si vous possédez déja linux passez directement à l'Étape 2.

- [X] Sauvegarder les données.

  Pour sauvegarder vos données vous pouvez au choix, copier vos données importantes (sur un disque externe ou sur le cloud) ou bien faire un “snapshot” de votre machine.

- [x] Télécharger une iso de Ubuntu.
  
  J’utilise [Ubuntu 24.04](https://releases.ubuntu.com/24.04.2/ubuntu-24.04.2-desktop-amd64.iso) qui est très stable et Open Source, ce sera la base de notre système d’exploitation customisé.

- [x] Créer une clé USB bootable
  
  On peut utiliser l’utilitaire [rufus](https://rufus.ie/fr/) pour créer la clé USB bootable.

> [!WARNING]  
>Rufus formate la clé, donc supprime toutes les données présentes. 

  Voici mon paramétrage:

<p align="center">  
  <img src="img/rufus.png">  
</p>

- [x] Installer Ubuntu 24.04 en dual boot.

  Il faut ensuite redémarrer sur la clé bootable.  
  (Windows 10)  Paramètres>Mise à jour et securité>Récupération>Redémarrage Avancé>Utiliser un Périphérique>USB Device>Install Ubuntu

### Tutos détaillés:

  Voici 2 tutos qui détaillent l’installation de Linux en Dual Boot:  
  [Le crabe info](https://lecrabeinfo.net/tutoriels/installer-ubuntu-24-04-lts-en-dual-boot-avec-windows/)  
  [IT-Connect](https://www.it-connect.fr/tuto-dual-boot-windows-et-linux-ubuntu-installation-sur-pc/)

- [x] Config Système.
 
   Choisir la partition que vous avez liberée.
   Vous pouvez ensuite procéder à l’installation et la configuration de votre choix (voir les tutos détaillés).

> [!WARNING]  
> Lors du choix du partitionnement faites attention à ne pas formater les partitions liées à Windows. Il est possible de créer de nouvelles partitions ou de cocher directement l'option "dual boot".


- [x] Mettre à jour le système.
  
  Il vaut mieux mettre à jour le système si des mises à jour sont proposées. ( Personnellement je désactive les mises à jour automatiques pour éviter des changements qui pourraient casser ma configuration).

> [!NOTE]  
> 🍿 L'installation peut prendre longtemps selon les PC (+ de 20 min pour moi). Si vous êtes connecté à Internet beaucoup de paquets peuvent être installé à ce moment-là.

## Étape 2 : Installer les Applications et Utilitaires.

- [x] Installer toutes les applications de votre choix.

> [!NOTE]  
> La configuration par défaut d'ArviX pourrait ne pas fonctionner si vous n'avez installé les mêmes applications que moi. Il suffira de remplacer les nom des programmes  que vous n'avez pas par un equivalent dans le fichier `arvix.conf`.

  Beaucoup d'apps sont disponibles sur le store "App Center" , mais vous pouvez aussi les télécharger depuis Internet.
  Pour une utilisation quotidienne de mon PC j'installe donc toutes les applications necessaires : Discord, Spotify, Steam, Libre Office, Firefox, Chrommonium, Visual Studio Code, PyCharm, Bitcoin, Gimp, VLC, Unreal ...

  Voilà le systeme est prêt : 
<p align="center">  
  <img src="img/ubuntu_desktop.png">  
</p>


###  Préparation et utilitaires nécessaires

- [ ] Installer Git, Curl, Wiget, Zsh
```shell
apt update && sudo apt upgrade
sudo apt install git curl wget zsh
```

- [ ] Cloner le répertoire git:

```shell
git clone https://github.com/Doritos-Man/Arvix
```


##  Étape 3 : GUI

>[!WARNING] Il est possible d'utiliser différents environnements graphique et de les personnaliser plus ou moins.

###  Hyprland

 Il est recommender de lire la documentation d'Hyprland sur le [site officiel](https://wiki.hypr.land/Getting-Started/Installation/) pour comprendre et maitriser votre configuration.

Il est possible d'utiliser plusieur paquets ubuntu d'hyperland `sudo apt-get install -y hyprland`ou d'utiliser des scripts disponibles sur github pour compiler Hyprland et les dependances. J'utilise les  scripts de [JaKooLit](https://github.com/JaKooLit/Ubuntu-Hyprland) qui contient plein d'outils, et propse des configurations d'Hyprland deja prètes.

Pour notre version (24.04):
```shell
git clone -b 24.04 --depth=1  https://github.com/JaKooLit/Ubuntu-Hyprland.git ~/Ubuntu-Hyprland-24.04
cd ~/Ubuntu-Hyprland-24.04
chmod +x install.sh
./install.sh
```
Au lancement du script vous couvez choisir quels composants installer, l'installation peut prendre plus de 10 minutes.

Voici un exemple d'une [configuration](https://github.com/Doritos-Man/Arvix/hyprland.conf) d'Hyprland (raccourcis personnalisés, styles, applis au démarage)

### GNOME

Si vous choisissez de garder l'environnement graphique par défaut d'Ubuntu vous pouvez utiliser des extensions de GNOME. Il est necéssaire d'installer le gestionnaire d'extension:
```shell
sudo apt install gnome-shell-extension-manager
```
Voilà plusieurs extensions très utiles:

> Open Bar : La meilleur extention de personnalisation pour le look des applications (bordures, couleurs, transparance) et de la barre du haut ou du dock.
>Vous pouvez les masquer, rendre transparent, changer les couleurs, les arrondis, etc.
> Il est possible d'inporter directement une [configuration](https://github.com/Doritos-Man/Arvix/hyprland.conf) dans Open Bar

> Add to Desktop : Permet de créer facilement un raccourci sur le bureau pour l'application que vous êtes en train d'utiliser.

> Blur my Shell : Ajoute un effet de flou (blur) esthétique aux éléments de l'interface GNOME (la barre du haut, le menu des applications, l'aperçu des fenêtres) pour un look plus moderne.

> Dash to Dock : Transforme le "Dash" (la barre de lancement cachée dans la vue d'ensemble) en un véritable dock permanent et hautement personnalisable (similaire à celui d'Apple).

> Forge : Un outil de "Tiling". Il range vos fenêtres côte à côte automatiquement pour remplir tout l'écran, comme sur Hyprland.

> Lockscreen Extension : Permet généralement de personnaliser l'apparence de l'écran de verrouillage.

> Media Controls : Affiche les boutons de contrôle de la musique (Lecture, Pause, Suivant/Précédent) directement dans la barre du haut, à côté de l'horloge.

> System Monitor : Affiche des graphiques en temps réel dans la barre du haut pour surveiller l'utilisation du processeur (CPU), de la mémoire (RAM) et du réseau.

## Fond d'ecran Animé

J'ai mis en place un fond d'écran dynamique pour Linux (GNOME) qui réagit en temps réel à la musique. Il ne s'active que lorsque du son est détecté, préservant ainsi les ressources du CPU/GPU lorsqu'il n'est pas nécessaire.Voir [ici](https://github.com/Doritos-Man/Arvix/bg-react-sonor).

>[!NOTE] Le bon fonctionnement de ce programme dépend fortement de vorte configuration personnelle.

### 🛠️ Architecture

Il y a 4 composants principaux :

1.  **Extraction Audio (Cava) :**
    * Utilisation de [Cava](https://github.com/karlstav/cava) pour capturer le flux audio brut (PulseAudio/PipeWire).
    * Sortie des données brutes vers un fichier `FIFO` (`/tmp/cava.fifo`) pour une latence minimale.

2.  **Pont WebSocket (Python) :**
    * Un script Python (`cava_ws.py`) lit le flux FIFO en temps réel.
    * Il transmet les données normalisées à une interface Web via un serveur WebSocket local (`ws://localhost:8765`).

3.  **Visualisation (HTML/JS) :**
    * Une page web locale (`index.html`) se connecte au WebSocket.
    * L'API Canvas dessine les courbes/barres par-dessus une image de fond.

4.  **Affichage (Wallpaper) :**
    * [Hidamari](https://github.com/jeffshee/hidamari) (Flatpak) pour gérer le rendu en fond d'écran.


### 📦 Installation & Prérequis

* **Dépendances :** `python3`, `cava`, `flatpak`, `ffmpeg`.
* **Librairies Python:** `websockets`, `pygobject`.

```shell

sudo apt install flatpak gnome-software-plugin-flatpak -y
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

flatpak install flathub io.github.jeffshee.Hidamari -y

sudo apt install cava -y

python3 -m venv --system-site-packages visualizer-env
source visualizer-env/bin/activate
pip install websockets
```

### 🎵 Utilisation

Pour lancer le fond d'ecran animé vous lancez  `./Arvix/bg-react-sonor/audio-script` (de préférence en arriere plan) et normalement dès que vous mettez de la musique (ou n'importe quel audio ) votre fond d'ércran s'anime au rythme du son :
