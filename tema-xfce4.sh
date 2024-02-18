#!/bin/bash
# Copyright 2020-2023 Joel Barrios <darkshram@gmail.com>

# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License as
# published by the Free Software Foundation; either version 3 of the
# License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Suite 500, MA 02110-1335, USA.
#
# License available at: https://www.gnu.org/licenses/gpl-3.0.en.html
#
# Author: Joel Barrios <darkshram@gmail.com>
# URL: https://github.com/darkshram/aldos-tools/

# https://techstop.github.io/bash-script-colors/
# Bold High Intensty
#
#| Value    | Color  |
#| -------- | ------ |
#| \e[1;90m | Black  |
#| \e[1;91m | Red    |
#| \e[1;92m | Green  |
#| \e[1;93m | Yellow |
#| \e[1;94m | Blue   |
#| \e[1;95m | Purple |
#| \e[1;96m | Cyan   |
#| \e[1;97m | White  |

# High Intensty backgrounds

#| Value     | Color  |
#| --------- | ------ |
#| \e[0;100m | Black  |
#| \e[0;101m | Red    |
#| \e[0;102m | Green  |
#| \e[0;103m | Yellow |
#| \e[0;104m | Blue   |
#| \e[0;105m | Purple |
#| \e[0;106m | Cyan   |
#| \e[0;107m | White  |

# Ansi color code variables
red="\e[0;91m"
blue="\e[0;94m"
#expand_bg="\e[K"
#blue_bg="\e[0;104m${expand_bg}"
#red_bg="\e[0;101m${expand_bg}"
#green_bg="\e[0;102m${expand_bg}"
green="\e[0;92m"
purple="\e[1;95m"
#purple_bg="\e[0;105m${expand_bg}"
#yellow="\e[1;93m"
#yellow_bg="\e[0;103m${expand_bg}"
white="\e[0;97m"
bold="\e[1m"
#uline="\e[4m"
reset="\e[0m"

# No usar como root.
if [ "$UID" -eq "0" ]; then
    echo -e "${red}${bold}    *** Este programa no debe ser usado como root ***${reset}"
    exit 1
fi

# Validar que usuario pertenezca al grupo wheel
if id -nG "${USER}" | grep -qw "wheel"; then
    true
else
    echo -e "${red}${bold}\n    El usuario '${USER}' require pertenecer al grupo 'wheel' para poder\n    usar este programa. Específicamente porque así lo requiere hardcode-tray,\n    pues éste necesita usar 'sudo' para poder hacer los cambios\n    correspondientes en el sistema.\n\n    Ejecuta como root lo siguiente:${reset}\n\n${bold}    gpasswd -a ${USER} wheel${reset}\n\n${red}${bold}    Luego ejecuta como root 'visudo' y descomenta la línea correspondiente a:${reset}\n\n    ${bold}%wheel        ALL=(ALL)       ALL\n${reset}\n\n    ${red}${bold}O bien, si prefieres usar 'sudo' sin contraseña, descomenta en su lugar\n    la línea correspondiente a:${reset}\n\n    ${bold}%wheel        ALL=(ALL)       NOPASSWD: ALL\n${reset}"
    exit 1
fi


# Validamos que se proporcione un argumento.
if [ $# -eq 0 ]; then
#    echo -e "${green}${bold} "
    echo -e "${green}${bold}  * Utilice el nombre de un tema como argumento."
    echo -e "${green}${bold}  * Uso: tema-xfce4.sh [Tema]"
    echo -e " "
    echo -e "${blue}${bold}Temas disponibles en ALDOS:${purple}${bold}"
    echo -e " ALDOS ALDOSDarker Adwaita AdwaitaDark Amber AmberCircle Andromeda Ant Arc"
    echo -e " ArcDarker BlueSky Chicago95 Cloudy ColloidDark ColloidLight Dracula"
    echo -e " DraculaCandy Fluent FluentDark Graphite Greybird Juno Kimi LaStrange Lavanda"
    echo -e " Layan Jasper JasperLight Midnight Materia MateriaDark MojaveDark MojaveLight"
    echo -e " Nordic NordicPolar Numix NumixCircle NumixSquare Otis Plano PlanoLight"
    echo -e " Qogir QogirDark QogirLight Redmond98 Redmond10 Redmond7 RedmondXP"
    echo -e " ShadesOfPurple Snow Sweet Vimix VimixDark WhiteSurDark WhiteSurLight"
    echo -e " "
    echo -e "${green}${bold}Ejemplos:"
    echo -e "${white}${bold}  tema-xfce4.sh ${purple}${bold}ALDOS"
    echo -e " "
    echo -e "${white}${bold}  tema-xfce4.sh ${purple}${bold}Amber"
    echo -e " "
    echo -e "${white}${bold}  tema-xfce4.sh ${purple}${bold}Arc"
    echo -e " "
    echo -e "${blue}${bold}* Use '${white}${bold}demo${blue}${bold}' como argumento para presentar todos los temas c/u por 20 seg."
    echo -e "${blue}${bold}  (Al final establecerá ${purple}${bold}ALDOS${blue}${bold} como tema.) "
    echo -e " "
    echo -n -e "${green}${bold}* Refrescando caché de yum con pkcon..."
    pkcon refresh > /dev/null 2>&1
    echo -e "${green}${bold} Hecho.${reset} "
    exit 1
fi

function ALDOS() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        nordic-cursor-theme arc-theme tela-icon-theme-nord || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        nordic-cursor-theme arc-theme tela-icon-theme-nord
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        nordic-cursor-theme arc-theme tela-icon-theme-nord && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Arc && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Nordic-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-nord && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Arc && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Nordic-cursors" && \
        gsettings set org.cinnamon.desktop.interface gtk-theme "Arc" && \
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-nord" && \
        gsettings set org.cinnamon.desktop.wm.preferences theme "Arc" && \
        gsettings set org.cinnamon.theme name "Arc"
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Nordic-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Arc" && \
        gsettings set org.gnome.desktop.interface icon-theme "Tela-nord" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Arc"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml ]; then
        gsettings set org.mate.interface icon-theme "Tela-nord" && \
        gsettings set org.mate.interface gtk-theme "Arc"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Nordic-cursors"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml ]; then
        gsettings set org.mate.Marco.general theme "Arc"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'ALDOS' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ALDOS' establecido"
}

function ALDOSDarker() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme tela-icon-theme-nord || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme tela-icon-theme-nord
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme tela-icon-theme-nord && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Arc-Darker && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Nordic-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-nord && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Arc-Darker && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Nordic-cursors" && \
        gsettings set org.cinnamon.desktop.interface gtk-theme "Arc" && \
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-nord" && \
        gsettings set org.cinnamon.desktop.wm.preferences theme "Arc-Darker" && \
        gsettings set org.cinnamon.theme name "Arc"
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Nordic-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Arc-Darker" && \
        gsettings set org.gnome.desktop.interface icon-theme "Tela-nord" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Arc-Darker"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'ALDOSDark' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ALDOSDark' establecido"
}

function ALDOSDark() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme tela-icon-theme-nord || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme tela-icon-theme-nord
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme tela-icon-theme-nord && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Arc-Dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Nordic-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-nord-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Arc-Dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Nordic-cursors" && \
        gsettings set org.cinnamon.desktop.interface gtk-theme "Arc-Dark" && \
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-nord" && \
        gsettings set org.cinnamon.desktop.wm.preferences theme "Arc-Dark" && \
        gsettings set org.cinnamon.theme name "Arc-Dark"
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Nordic-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark" && \
        gsettings set org.gnome.desktop.interface icon-theme "Tela-nord-dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Arc-Dark"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'ALDOSDark' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ALDOSDark' establecido"
}

function BlueSky() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme bluesky-gtk-theme papirus-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme bluesky-gtk-theme papirus-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme bluesky-gtk-theme papirus-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s BlueSky && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s BlueSky && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.cinnamon.desktop.interface gtk-theme "BlueSky" && \
        gsettings set org.cinnamon.desktop.interface icon-theme "Papirus" && \
        gsettings set org.cinnamon.desktop.wm.preferences theme "BlueSky" && \
        gsettings set org.cinnamon.theme name "BlueSky"
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "BlueSky" && \
        gsettings set org.gnome.desktop.interface icon-theme "Papirus" && \
        gsettings set org.gnome.desktop.wm.preferences theme "BlueSky"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml ]; then
        gsettings set org.mate.interface icon-theme "Papirus" && \
        gsettings set org.mate.interface gtk-theme "BlueSky"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Adwaita"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml ]; then
        gsettings set org.mate.Marco.general theme "BlueSky"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'BlueSky' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'BlueSky' establecido"
}

function Midnight() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme midnight-gtk-theme papirus-dark-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme midnight-gtk-theme papirus-dark-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme midnight-gtk-theme papirus-dark-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Midnight && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus-Dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Midnight && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.cinnamon.desktop.interface gtk-theme "Midnight" && \
        gsettings set org.cinnamon.desktop.interface icon-theme "Papirus-Dark" && \
        gsettings set org.cinnamon.desktop.wm.preferences theme "Midnight" && \
        gsettings set org.cinnamon.theme name "Midnight"
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Midnight" && \
        gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Midnight"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml ]; then
        gsettings set org.mate.interface icon-theme "Papirus-Dark" && \
        gsettings set org.mate.interface gtk-theme "Midnight"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Adwaita"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml ]; then
        gsettings set org.mate.Marco.general theme "Midnight"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Midnight' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Midnight' establecido"
}

function Cloudy() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme cloudy-gtk-theme papirus-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme cloudy-gtk-theme papirus-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme cloudy-gtk-theme papirus-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Cloudy && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Cloudy && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.cinnamon.desktop.interface gtk-theme "Cloudy" && \
        gsettings set org.cinnamon.desktop.interface icon-theme "Papirus" && \
        gsettings set org.cinnamon.desktop.wm.preferences theme "Cloudy" && \
        gsettings set org.cinnamon.theme name "Arc"
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Cloudy" && \
        gsettings set org.gnome.desktop.interface icon-theme "Papirus" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Cloudy"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml ]; then
        gsettings set org.mate.interface icon-theme "Papirus" && \
        gsettings set org.mate.interface gtk-theme "Cloudy"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Adwaita"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml ]; then
        gsettings set org.mate.Marco.general theme "Cloudy"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Cloudy' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Cloudy' establecido"
}

function Lavanda() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        fluent-cursor-theme bluesky-gtk-theme papirus-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        fluent-cursor-theme bluesky-gtk-theme papirus-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        fluent-cursor-theme bluesky-gtk-theme papirus-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Lavanda && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Fluent-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-circle && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Lavanda && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Fluent-cursors" && \
        gsettings set org.cinnamon.desktop.interface gtk-theme "Lavanda" && \
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-circle" && \
        gsettings set org.cinnamon.desktop.wm.preferences theme "Lavanda" && \
        gsettings set org.cinnamon.theme name "Arc"
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Fluent-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Lavanda" && \
        gsettings set org.gnome.desktop.interface icon-theme "Tela-circle" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Lavanda"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml ]; then
        gsettings set org.mate.interface icon-theme "Tela-circle" && \
        gsettings set org.mate.interface gtk-theme "Lavanda"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Fluent-cursors"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml ]; then
        gsettings set org.mate.Marco.general theme "Lavanda"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Lavanda' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Lavanda' establecido"
}

function ShadesOfPurple() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        layan-cursor-theme shades-of-purple-gtk-theme candy-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        layan-cursor-theme shades-of-purple-gtk-theme candy-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        layan-cursor-theme shades-of-purple-gtk-theme candy-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Shades-of-purple && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Layan-white-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Candy && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Shades-of-purple && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Layan-white-cursors" && \
        gsettings set org.cinnamon.desktop.interface gtk-theme "Shades-of-purple" && \
        gsettings set org.cinnamon.desktop.interface icon-theme "Candy" && \
        gsettings set org.cinnamon.desktop.wm.preferences theme "Shades-of-purple" && \
        gsettings set org.cinnamon.theme name "Shades-of-purple"
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Layan-white-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Shades-of-purple" && \
        gsettings set org.gnome.desktop.interface icon-theme "Candy" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Shades-of-purple"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml ]; then
        gsettings set org.mate.interface icon-theme "Candy" && \
        gsettings set org.mate.interface gtk-theme "Shades-of-purple"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Layan-white-cursors"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml ]; then
        gsettings set org.mate.Marco.general theme "Shades-of-purple"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Shades-of-purple' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Shades-of-purple' establecido"
}

function Plano() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme plano-theme tela-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme plano-theme tela-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme plano-theme tela-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Plano-dark-titlebar && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Plano-dark-titlebar && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Numix" && \
        gsettings set org.cinnamon.desktop.interface gtk-theme "Plano-dark-titlebar" && \
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela" && \
        gsettings set org.cinnamon.desktop.wm.preferences theme "Plano" && \
        gsettings set org.cinnamon.theme name "Adwaita"
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Plano-dark-titlebar" && \
        gsettings set org.gnome.desktop.interface icon-theme "Tela" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Plano"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Plano' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Plano' establecido"
}

function PlanoLight() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme plano-theme tela-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme plano-theme tela-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme plano-theme tela-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Plano && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Plano && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Plano" && \
        gsettings set org.gnome.desktop.interface icon-theme "Numix" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Plano"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'PlanoLight' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'PlanoLight' establecido"
}

function Amber() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-icon-theme numix-cursor-theme amber-theme tela-icon-theme-black || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-icon-theme numix-cursor-theme amber-theme tela-icon-theme-black
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-icon-theme numix-cursor-theme amber-theme tela-icon-theme-black && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Amber && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Amber && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Amber" && \
        gsettings set org.gnome.desktop.interface icon-theme "Numix" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Amber"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Amber' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Amber' establecido"
}

function AmberCircle() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme amber-theme numix-icon-theme-circle || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme amber-theme numix-icon-theme-circle
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme amber-theme numix-icon-theme-circle && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Amber && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Numix-Circle && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Amber && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Amber" && \
        gsettings set org.gnome.desktop.interface icon-theme "Numix-Circle" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Amber"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Amber' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Amber' establecido"
}

function Arc() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        arc-theme papirus-icon-theme adwaita-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme papirus-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        arc-theme papirus-icon-theme adwaita-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Arc && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Arc && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Arc" && \
        gsettings set org.gnome.desktop.interface icon-theme "Papirus" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Arc"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Arc' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Arc' establecido"
}

function ArcDarker() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        arc-theme papirus-icon-theme adwaita-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        arc-theme papirus-icon-theme adwaita-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        arc-theme papirus-icon-theme adwaita-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Arc-Darker && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus-Dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Arc-Darker && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Arc-Darker" && \
        gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Arc-Darker"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'ArcDarker' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ArcDarker' establecido"
}

function ArcDark() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        arc-theme papirus-icon-theme adwaita-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme papirus-icon-theme adwaita-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        arc-theme papirus-icon-theme adwaita-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Arc-Dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus-Dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Arc-Dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark" && \
        gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Arc-Dark"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'ArcDark' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ArcDark' establecido"
}

function Numix() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme numix-gtk-theme numix-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme numix-gtk-theme numix-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme numix-gtk-theme numix-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Numix && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Numix" && \
        gsettings set org.gnome.desktop.interface icon-theme "Numix" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Numix"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Numix' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Numix' establecido"
}

function NumixCircle() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme numix-gtk-theme numix-icon-theme-circle || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme numix-gtk-theme numix-icon-theme-circle
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme numix-gtk-theme numix-icon-theme-circle && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Numix && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Numix-Circle && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Numix" && \
        gsettings set org.gnome.desktop.interface icon-theme "Numix-Circle" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Numix"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'NumixCircle' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'NumixCircle' establecido"
}

function NumixSquare() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme numix-gtk-theme numix-icon-theme-square || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme numix-gtk-theme numix-icon-theme-square
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme numix-gtk-theme numix-icon-theme-square && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Numix && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Numix-Square && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Numix" && \
        gsettings set org.gnome.desktop.interface icon-theme "Numix-Square" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Numix"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'NumixSquare' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'NumixSquare' establecido"
}

function Greybird() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        dmz-cursor-themes greybird-light-theme greybird-xfwm4-theme elementary-xfce-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        dmz-cursor-themes greybird-light-theme greybird-xfwm4-theme elementary-xfce-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        dmz-cursor-themes greybird-light-theme greybird-xfwm4-theme elementary-xfce-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Greybird && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s DMZ-Black && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s elementary-xfce-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Greybird && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "DMZ-Black" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Greybird" && \
        gsettings set org.gnome.desktop.interface icon-theme "elementary-xfce-dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Greybird"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Grebird' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Grebird' establecido"
}

function Ant() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        ant-gtk-theme boston-icon-theme adwaita-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        ant-gtk-theme boston-icon-theme adwaita-cursor-theme 
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        ant-gtk-theme boston-icon-theme adwaita-cursor-theme  && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Ant && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Boston && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Ant && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Ant" && \
        gsettings set org.gnome.desktop.interface icon-theme "Boston" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Ant"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Ant' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Ant' establecido"
}

function Kimi() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        kimi-gtk-theme tela-icon-theme-purple adwaita-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        kimi-gtk-theme tela-icon-theme-purple adwaita-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        kimi-gtk-theme tela-icon-theme-purple adwaita-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Kimi && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-purple && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Kimi  && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Kimi" && \
        gsettings set org.gnome.desktop.interface icon-theme "Tela-purple" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Kimi"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Kimi' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Kimi' establecido"
}

function Juno() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        juno-gtk-theme zafiro-icon-theme adwaita-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        juno-gtk-theme zafiro-icon-theme adwaita-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        juno-gtk-theme zafiro-icon-theme adwaita-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Juno && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Zafiro-icons && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Juno  && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Juno" && \
        gsettings set org.gnome.desktop.interface icon-theme "Zafiro-icons" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Juno"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Juno' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Juno' establecido"
}

function Otis() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        otis-gtk-theme candy-icon-theme adwaita-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        otis-gtk-theme candy-icon-theme adwaita-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        otis-gtk-theme candy-icon-theme adwaita-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Otis && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Candy && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Otis  && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Otis" && \
        gsettings set org.gnome.desktop.interface icon-theme "Candy" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Otis"
fi
if [ -e /usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.cinnamon.desktop.interface gtk-theme "Otis" && \
        gsettings set org.cinnamon.desktop.interface icon-theme "Candy" && \
        gsettings set org.cinnamon.desktop.wm.preferences theme "Otis" && \
        gsettings set org.cinnamon.theme name "Otis"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml ]; then
        gsettings set org.mate.interface icon-theme "Candy" && \
        gsettings set org.mate.interface gtk-theme "Otis"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Adwaita"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml ]; then
        gsettings set org.mate.Marco.general theme "Otis"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Otis' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Otis' establecido"
}

function Andromeda() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        andromeda-gtk-theme zafiro-icon-theme adwaita-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        andromeda-gtk-theme zafiro-icon-theme adwaita-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        andromeda-gtk-theme zafiro-icon-theme adwaita-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Andromeda && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Zafiro-icons && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Andromeda  && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Andromeda" && \
        gsettings set org.gnome.desktop.interface icon-theme "Zafiro-icons" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Andromeda"
fi
if [ -e /usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.cinnamon.desktop.interface gtk-theme "Andromeda" && \
        gsettings set org.cinnamon.desktop.interface icon-theme "Candy" && \
        gsettings set org.cinnamon.desktop.wm.preferences theme "Andromeda" && \
        gsettings set org.cinnamon.theme name "Andromeda"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml ]; then
        gsettings set org.mate.interface icon-theme "Zafiro-icons" && \
        gsettings set org.mate.interface gtk-theme "Andromeda"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Adwaita"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml ]; then
        gsettings set org.mate.Marco.general theme "Andromeda"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Andromeda' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Andromeda' establecido"
}

function Snow() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        snow-gtk-theme boston-icon-theme adwaita-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        snow-gtk-theme boston-icon-theme adwaita-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        snow-gtk-theme boston-icon-theme adwaita-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Snow && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Boston && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Snow  && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Snow" && \
        gsettings set org.gnome.desktop.interface icon-theme "Boston" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Snow"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Snow' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Snow' establecido"
}

function Sweet() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        sweet-gtk-theme boston-icon-theme adwaita-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        sweet-gtk-theme boston-icon-theme adwaita-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        sweet-gtk-theme boston-icon-theme adwaita-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Sweet && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Boston && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Sweet  && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Sweet" && \
        gsettings set org.gnome.desktop.interface icon-theme "Boston" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Sweet"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Sweet' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Sweet' establecido"
}

function Dracula() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        dracula-gtk-theme tela-circle-dracula-icon-theme dracula-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        dracula-gtk-theme tela-circle-dracula-icon-theme dracula-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        dracula-gtk-theme tela-circle-dracula-icon-theme dracula-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Dracula && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Dracula-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-circle-dracula-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Dracula && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Dracula-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Dracula" && \
        gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-dracula-dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Dracula"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml ]; then
        gsettings set org.mate.interface icon-theme "Tela-circle-dracula-dark" && \
        gsettings set org.mate.interface gtk-theme "Dracula"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Dracula-cursors"
fi
if [ -e /usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml ]; then
        gsettings set org.mate.Marco.general theme "Dracula"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Dracula' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Dracula' establecido"
}

function DraculaCandy() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        dracula-gtk-theme candy-icon-theme dracula-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        dracula-gtk-theme candy-icon-theme dracula-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        dracula-gtk-theme candy-icon-theme dracula-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Dracula && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Dracula-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Candy && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Dracula && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Dracula-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Dracula" && \
        gsettings set org.gnome.desktop.interface icon-theme "Candy" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Dracula"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Dracula' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Dracula' establecido"
}

function Jasper() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        jasper-gtk-theme fluent-icon-theme-teal fluent-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        jasper-gtk-theme fluent-icon-theme-teal fluent-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        jasper-gtk-theme fluent-icon-theme-teal fluent-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Jasper-Dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Fluent-dark-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Fluent-teal-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Jasper-Dark  && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Fluent-dark-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Jasper-Dark" && \
        gsettings set org.gnome.desktop.interface icon-theme "Fluent-teal-dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Jasper-Dark"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Jasper' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Jasper' establecido"
}

function JasperLight() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        jasper-gtk-theme fluent-icon-theme-teal fluent-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        jasper-gtk-theme fluent-icon-theme-teal fluent-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        jasper-gtk-theme fluent-icon-theme-teal fluent-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Jasper-Light && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Fluent-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Fluent-teal && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Jasper-Light  && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Fluent-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Jasper-Light" && \
        gsettings set org.gnome.desktop.interface icon-theme "Fluent-teal" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Jasper-Light"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'JasperLight' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'JasperLight' establecido"
}

function Graphite() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        graphite-gtk-theme tela-circle-black-icon-theme graphite-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        graphite-gtk-theme tela-circle-black-icon-theme graphite-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        graphite-gtk-theme tela-circle-black-icon-theme graphite-cursor-theme && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Graphite-Dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Graphite-dark-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-circle-black-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Graphite-Dark  && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Graphite-dark-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Graphite-Dark" && \
        gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-black-dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Graphite-Dark"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Graphite' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Graphite' establecido"
}

function GraphiteLight() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        graphite-gtk-theme tela-circle-black-icon-theme graphite-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        graphite-gtk-theme tela-circle-black-icon-theme graphite-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        graphite-gtk-theme tela-circle-black-icon-theme graphite-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Graphite-Light && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Graphite-light-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-circle-black && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Graphite-Light  && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Graphite-light-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Graphite-Light" && \
        gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-black" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Graphite-Light"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'GraphiteLight' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'GraphiteLight' establecido"
}

function ColloidDark() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        colloid-gtk-theme colloid-icon-theme colloid-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        colloid-gtk-theme colloid-icon-theme colloid-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        colloid-gtk-theme colloid-icon-theme colloid-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Colloid-Dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Colloid-dark-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Colloid-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Colloid-Dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Colloid-dark-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Colloid-Dark" && \
        gsettings set org.gnome.desktop.interface icon-theme "Colloid-dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Colloid-Dark"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'ColloidDark' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ColloidDark' establecido"
}

function ColloidLight() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        colloid-gtk-theme colloid-icon-theme colloid-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        colloid-gtk-theme colloid-icon-theme colloid-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        colloid-gtk-theme colloid-icon-theme colloid-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Colloid-Light && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Colloid-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Colloid-light && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Colloid-Light && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Colloid-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Colloid-Light" && \
        gsettings set org.gnome.desktop.interface icon-theme "Colloid-light" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Colloid-Light"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'ColloidLight' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ColloidLight' establecido"
}

function Layan() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme layan-gtk-theme tela-icon-theme layan-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme layan-gtk-theme tela-icon-theme layan-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme layan-gtk-theme tela-icon-theme layan-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Layan && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Layan-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Layan && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Layan-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Layan" && \
        gsettings set org.gnome.desktop.interface icon-theme "Tela" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Layan"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Layan' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Layan' establecido"
}

function Nordic() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme nordic-gtk-theme zafiro-icon-theme nordic-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme nordic-gtk-theme zafiro-icon-theme nordic-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme nordic-gtk-theme zafiro-icon-theme nordic-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Nordic && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Nordic-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Zafiro-icons && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Nordic && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Nordic-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Nordic" && \
        gsettings set org.gnome.desktop.interface icon-theme "Zafiro-icons" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Nordic"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Nordic' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Nordic' establecido"
}

function NordicPolar() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme nordic-polar-gtk-theme zafiro-icon-theme nordic-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme nordic-polar-gtk-theme zafiro-icon-theme nordic-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme nordic-polar-gtk-theme zafiro-icon-theme nordic-cursor-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Nordic-Polar && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Nordic-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Zafiro-icons-Light && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Nordic-Polar && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Nordic-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Nordic-Polar" && \
        gsettings set org.gnome.desktop.interface icon-theme "Zafiro-icons-Light" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Nordic-Polar"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'NordicPolar' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'NordicPolar' establecido"
}

function Adwaita() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme gnome-themes-extra adwaita-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme gnome-themes-extra adwaita-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme gnome-themes-extra adwaita-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Default && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface icon-theme "Adwaita" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Adwaita"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Adwaita' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Adwaita' establecido"
}

function AdwaitaDark() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme gnome-themes-extra adwaita-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme gnome-themes-extra adwaita-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme gnome-themes-extra adwaita-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Default && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Adwaita-dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark" && \
        gsettings set org.gnome.desktop.interface icon-theme "Adwaita" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Adwaita"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'AdwaitaDark' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'AdwaitaDark' establecido"
}

function Materia() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme materia-gtk-theme papirus-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme materia-gtk-theme papirus-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme materia-gtk-theme papirus-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Materia-compact && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Materia-compact && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Materia-compact" && \
        gsettings set org.gnome.desktop.interface icon-theme "Papirus" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Materia-compact"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Materia' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Materia' establecido"
}

function MateriaDark() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme materia-gtk-theme papirus-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme materia-gtk-theme papirus-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme materia-gtk-theme papirus-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Materia-dark-compact && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus-Dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Materia-dark-compact && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Materia-dark-compact" && \
        gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Materia-dark-compact"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'MateriaDark' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'MateriaDark' establecido"
}

function Vimix() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        vimix-cursor-theme vimix-gtk-theme vimix-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        vimix-cursor-theme vimix-gtk-theme vimix-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        vimix-cursor-theme vimix-gtk-theme vimix-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Vimix && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Vimix-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Vimix && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Vimix && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Vimix-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Vimix" && \
        gsettings set org.gnome.desktop.interface icon-theme "Vimix" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Vimix"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Vimix' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Vimix' establecido"
}

function VimixDark() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        vimix-gtk-theme vimix-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        vimix-gtk-theme vimix-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        vimix-gtk-theme vimix-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Vimix-dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Vimix-white-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Vimix-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Vimix-dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Vimix-white-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Vimix-dark" && \
        gsettings set org.gnome.desktop.interface icon-theme "Vimix-dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Vimix-dark"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'VimixDark' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'VimixDark' establecido"
}

function MojaveLight() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        mojave-gtk-theme mcmojave-cursor-theme mcmojave-circle-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        mojave-gtk-theme mcmojave-cursor-theme mcmojave-circle-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        mojave-gtk-theme mcmojave-cursor-theme mcmojave-circle-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Mojave-Light && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s McMojave-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s McMojave-circle && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Mojave-Light && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "McMojave-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Mojave-Light" && \
        gsettings set org.gnome.desktop.interface icon-theme "McMojave-circle" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Mojave-Light"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'MojaveLight' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'MojaveLight' establecido"
}

function MojaveDark() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        mojave-gtk-theme mcmojave-cursor-theme mcmojave-circle-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        mojave-gtk-theme mcmojave-cursor-theme mcmojave-circle-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        mojave-gtk-theme mcmojave-cursor-theme mcmojave-circle-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Mojave-Dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s McMojave-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s McMojave-circle-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Mojave-Dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "McMojave-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Mojave-Dark" && \
        gsettings set org.gnome.desktop.interface icon-theme "McMojave-circle-dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Mojave-Dark"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'MojaveDark' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'MojaveDark' establecido"
}

function WhiteSurLight() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        whitesur-gtk-theme whitesur-cursor-theme whitesur-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        whitesur-gtk-theme whitesur-cursor-theme whitesur-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        whitesur-gtk-theme whitesur-cursor-theme whitesur-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s WhiteSur-Light && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s WhiteSur-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s WhiteSur && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s WhiteSur-Light && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Light" && \
        gsettings set org.gnome.desktop.interface icon-theme "WhiteSur" && \
        gsettings set org.gnome.desktop.wm.preferences theme "WhiteSur-Light"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'WhiteSurLight' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'WhiteSurLight' establecido"
}

function WhiteSurDark() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        whitesur-gtk-theme whitesur-cursor-theme whitesur-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        whitesur-gtk-theme whitesur-cursor-theme whitesur-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        whitesur-gtk-theme whitesur-cursor-theme whitesur-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s WhiteSur-Dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s WhiteSur-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s WhiteSur-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s WhiteSur-Dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark" && \
        gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "WhiteSur-Dark"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'WhiteSurDark' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'WhiteSurDark' establecido"
}

function OrchisDark() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        orchis-gtk-theme tela-circle-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        orchis-gtk-theme tela-circle-icon-theme || \
        rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        orchis-gtk-theme tela-circle-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Orchis-dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Vimix-dark && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-circle-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Orchis-dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Vimix-dark" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Orchis-dark" && \
        gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Orchis-dark"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'OrchisDark' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'OrchisDark' establecido"
}

function Qogir() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        qogir-gtk-theme qogir-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        qogir-gtk-theme qogir-icon-theme || \
        rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        qogir-gtk-theme qogir-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Qogir && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Qogir && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Qogir && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Qogir && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Qogir" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Qogir" && \
        gsettings set org.gnome.desktop.interface icon-theme "Qogir" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Qogir"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Qogir' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Qogir' establecido"
}

function QogirDark() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        qogir-gtk-theme qogir-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        qogir-gtk-theme qogir-icon-theme || \
        rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        qogir-gtk-theme qogir-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Qogir-Dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Qogir-Dark && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Qogir-Dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Qogir-Dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Qogir-Dark" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Qogir-Dark" && \
        gsettings set org.gnome.desktop.interface icon-theme "Qogir-Dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Qogir-Dark"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'QogirDark' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'QogirDark' establecido"
}

function QogirLight() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        qogir-gtk-theme qogir-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        qogir-gtk-theme qogir-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        qogir-gtk-theme qogir-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Qogir-Light && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Qogir && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Qogir-Light && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Qogir-Light && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Qogir" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Qogir-Light" && \
        gsettings set org.gnome.desktop.interface icon-theme "Qogit-Light" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Qogit-Light"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'QogirLight' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'QogirLight' establecido"
}

function Fluent() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        fluent-gtk-theme fluent-cursor-theme fluent-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        fluent-gtk-theme fluent-cursor-theme fluent-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        fluent-gtk-theme fluent-cursor-theme fluent-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Fluent && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Fluent-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Fluent-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Fluent && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Fluent-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Fluent" && \
        gsettings set org.gnome.desktop.interface icon-theme "Fluent-dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Fluent"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Fluent' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'fluent' establecido"
}

function FluentDark() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        fluent-gtk-theme fluent-cursor-theme fluent-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        fluent-gtk-theme fluent-cursor-theme fluent-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        fluent-gtk-theme fluent-cursor-theme fluent-icon-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Fluent-Dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Fluent-dark-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Fluent-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Fluent-Dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Fluent-dark-cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Fluent-Dark" && \
        gsettings set org.gnome.desktop.interface icon-theme "Fluent-dark" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Fluent-Dark"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'FluentDark' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'FluentDark' establecido"
}

function Chicago95() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        chicago95-cursor-theme chicago95-gtk-theme chicago95-icon-theme \
        chicago95-sound-theme chicago95-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        chicago95-cursor-theme chicago95-gtk-theme chicago95-icon-theme \
        chicago95-sound-theme chicago95-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        chicago95-cursor-theme chicago95-gtk-theme chicago95-icon-theme \
        chicago95-sound-theme chicago95-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Chicago95 && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Chicago95_Animated_Hourglass_Cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Chicago95 && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Chicago95 && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Chicago95 && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarTreePane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Chicago95_Animated_Hourglass_Cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Chicago95" && \
        gsettings set org.gnome.desktop.interface icon-theme "Chicago95" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Chicago95"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Chicago95' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Chicago95' establecido"
}

function Redmond98() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        chicago95-cursor-theme chicago95-gtk-theme redmond98se-icon-theme \
        chicago95-sound-theme chicago95-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        chicago95-cursor-theme chicago95-gtk-theme redmond98se-icon-theme \
        chicago95-sound-theme chicago95-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        chicago95-cursor-theme chicago95-gtk-theme redmond98se-icon-theme \
        chicago95-sound-theme chicago95-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Chicago95 && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Chicago95_Animated_Hourglass_Cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Redmond98SE && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Chicago95 && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Chicago95 && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarTreePane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Chicago95_Animated_Hourglass_Cursors" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Chicago95" && \
        gsettings set org.gnome.desktop.interface icon-theme "Redmond98SE" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Chicago95"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Chicago95' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Chicago95' establecido"
}

function RedmondXP() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        redmondxp-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        redmondxp-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        redmondxp-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s RedmondXP_Luna && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s DMZ-White && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s RedmondXP && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s RedmondXP_Luna && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarTreePane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "DMZ-White" && \
        gsettings set org.gnome.desktop.interface gtk-theme "RedmondXP" && \
        gsettings set org.gnome.desktop.interface icon-theme "RedmondXP" && \
        gsettings set org.gnome.desktop.wm.preferences theme "RedmondXP"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'RedmondXP' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'RedmondXP' establecido"
}

function Redmond7() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        redmond7-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        redmond7-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        redmond7-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Redmond7 && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s DMZ-White && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Redmond7 && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Redmond7 && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "DMZ-White" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Redmond7" && \
        gsettings set org.gnome.desktop.interface icon-theme "Redmond7" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Redmond7"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Redmond7' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Redmond7' establecido"
}

function Redmond10() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        redmond10-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        Redmond10-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        redmond10-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Redmond10 && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s DMZ-White && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Redmond10 && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Redmond10 && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "DMZ-White" && \
        gsettings set org.gnome.desktop.interface gtk-theme "Redmond10" && \
        gsettings set org.gnome.desktop.interface icon-theme "Redmond10" && \
        gsettings set org.gnome.desktop.wm.preferences theme "Redmond10"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Redmond10' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Redmond10' establecido"
}

function LaStrange() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme lastrange-icon-theme lastrange-gtk-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme lastrange-icon-theme lastrange-gtk-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme lastrange-icon-theme lastrange-gtk-theme && \
if [ -e /etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s LaStrange && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s LaStrange && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s LaStrange && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarTreePane
fi
if [ -e /usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita" && \
        gsettings set org.gnome.desktop.interface gtk-theme "LaStrange" && \
        gsettings set org.gnome.desktop.interface icon-theme "LaStrange" && \
        gsettings set org.gnome.desktop.wm.preferences theme "LaStrange"
fi
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'LaStrange' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'LaStrange' establecido"
}

function demo() {

    for TESTTHEME in \
       ALDOS ALDOSDarker Adwaita Amber AmberCircle Andromeda Ant Arc ArcDarker BlueSky \
       Chicago95 Cloudy ColloidDark ColloidLight Dracula DraculaCandy Fluent FluentDark \
       Greybird Jasper JasperLight Juno Kimi LaStrange Lavanda Layan Materia MateriaDark \
       MojaveDark MojaveLight Nordic NordicPolar Numix NumixCircle NumixSquare Otis Plano \
       PlanoLight Qogir QogirDark QogirLight Redmond10 Redmond7 RedmondXP ShadesOfPurple \
       Snow Sweet Vimix VimixDark WhiteSurDark WhiteSurLight ALDOS
    do
       ${TESTTHEME} ; sleep 20
    done
}

$1
