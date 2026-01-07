import gi
import sys
import signal

# On s'assure d'utiliser les versions stables
gi.require_version('Gtk', '3.0')
gi.require_version('WebKit2', '4.0')

from gi.repository import Gtk, Gdk, WebKit2

class WallpaperBrowser(Gtk.Window):
    def __init__(self, url):
        super().__init__(title="Wallpaper")

        # Configuration de la fenêtre pour agir comme un fond d'écran
        self.set_type_hint(Gdk.WindowTypeHint.DESKTOP) # Indique que c'est un bureau
        self.set_keep_below(True)                      # Reste toujours en dessous
        self.set_decorated(False)                      # Pas de barre de titre
        self.set_accept_focus(False)                   # Ne prend pas le clavier
        self.set_skip_taskbar_hint(True)               # Caché de la barre des tâches
        self.set_skip_pager_hint(True)                 # Caché du Alt+Tab
        
        # Plein écran
        screen = Gdk.Screen.get_default()
        monitor = screen.get_primary_monitor() # Ou adapte selon ton écran
        geometry = screen.get_monitor_geometry(monitor)
        self.move(geometry.x, geometry.y)
        self.resize(geometry.width, geometry.height)

        # Création du navigateur WebKit
        self.webview = WebKit2.WebView()
        
        # Fond transparent (optionnel, pour éviter le flash blanc)
        rgba = Gdk.RGBA()
        rgba.parse("black")
        self.webview.set_background_color(rgba)

        # Charger l'URL
        self.webview.load_uri(url)
        
        # Ajouter le navigateur à la fenêtre
        self.add(self.webview)

    def close_app(self, *args):
        Gtk.main_quit()

if __name__ == "__main__":
    url = "http://localhost:8000"
    if len(sys.argv) > 1:
        url = sys.argv[1]

    win = WallpaperBrowser(url)
    
    # Gestion propre de l'arrêt (Ctrl+C ou kill)
    signal.signal(signal.SIGINT, signal.SIG_DFL)
    win.connect("destroy", Gtk.main_quit)
    
    win.show_all()
    Gtk.main()