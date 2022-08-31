# aldos-tools
A collection of tools for ALDOS desktop

## tema-xfce4.sh
This tool is a theme switcher and works only in ALDOS.

To install, open a terminal and execute:
```
mkdir -p ~/.local/bin/
wget -P ~/.local/bin/ https://raw.githubusercontent.com/darkshram/aldos-tools/main/tema-xfce4.sh
chmod +x ~/.local/bin/tema-xfce4.sh
```
Works from terminal. **Requires a regular user account configured to use sudo** because the use of hardcode-tray, **but it should not be used directly with sudo**. Just execute it without arguments ***as regular user*** and it will explain itself how to use it. To switch theme in Xfce, just execute it with the name of the theme (in the list of supported themes) as argument. Program itself will download and install (using sudo) everything needed for ALDOS, including hardcode-tray to fix the hardcoded tray icons (this part also requires sudo).

```
 
  * Utilice el nombre de un tema como argumento.
  * Uso: tema-xfce4.sh [Tema]
 
Temas disponibles en ALDOS:
 ALDOS ALDOSDarker Adwaita Amber AmberCircle Ant Arc ArcDarker Chicago95
 ColloidDark ColloidLight Dracula DraculaCandy Fluent FluentDark Greybird
 Kimi LaStrange Layan Materia MateriaDark MojaveDark MojaveLight Nephrite
 NephriteLight Nordic NordicPolar Numix NumixCircle NumixSquare Otis Plano
 PlanoLight Qogir QogirDark QogirLight Redmond10 Redmond7 RedmondXP Snow
 Vimix VimixDark WhiteSurDark WhiteSurLight
 
Ejemplos:
  tema-xfce4.sh ALDOS
 
  tema-xfce4.sh Amber
 
  tema-xfce4.sh Arc
 
* Use 'demo' como argumento para presentar todos los temas c/u por 20 seg.
  (Al final establecerá ALDOS como tema.) 
 
* Refrescando caché de yum con pkcon... Hecho. 
```
