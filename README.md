# aldos-tools
A collection of tools for ALDOS desktop

## tema-xfce4.sh
This tool is a theme switcher and wotrks only in ALDOS. Works from terminal. ***Requires a regular user account configured to use sudo*** but it should not be used directly with sudo. Just execute it without arguments ***as regular user*** and it will explain itself how to use it. To switch theme in Xfce, just execute it with the name of the theme (in the list of supported themes) as argument. Program itself will download and install (using sudo) everything needed for ALDOS, including hardcode-tray to fix the hardcoded tray icons (this part also requires sudo).

```
 
  * Se requiere el nombre de un tema como argumento.
  * Uso: /home/jbarrios/.local/bin/tema-xfce4.sh Tema
 
  Temas disponibles:
   ALDOS Adwaita Amber AmberCircle Arc ArcDarker Chicago95 Greybird LaStrange
   Materia MateriaDark MojaveDark MojaveLight Nordic NordicPolar Numix
   NumixCircle NumixSquare OrchisDark Plano PlanoLight Qogir QogirDark
   QogirLight Redmond10 Redmond7 RedmondXP Vimix VimixDark WhiteSurDark
   WhiteSurLight
 
  Ejemplos:
  /home/jbarrios/.local/bin/tema-xfce4.sh ALDOS
 
  /home/jbarrios/.local/bin/tema-xfce4.sh Amber
 
  /home/jbarrios/.local/bin/tema-xfce4.sh Arc
 
* Use 'demo' como argumento para presentar todos los temas c/u por 20 seg.
  (Al final establecerá ALDOS como tema.) 
 
* Refrescando caché de yum con pkcon... Hecho.
```
