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
# Ansi color code variables
red="\e[0;91m"
blue="\e[0;94m"
green="\e[0;92m"
purple="\e[1;95m"
white="\e[0;97m"
bold="\e[1m"
reset="\e[0m"

# No usar como root.
if [ "$UID" -eq "0" ]; then
    printf "%b\n" "${red}${bold}    *** Este programa no debe ser usado como root ***${reset}"
    exit 1
fi

# Validar que usuario pertenezca al grupo wheel
if id -nG "${USER}" | grep -qw "wheel"; then
    true
else
    printf "%b\n" "${red}${bold}\n    El usuario '${USER}' requiere pertenecer al grupo 'wheel' para poder\n    usar este programa. Específicamente porque así lo requiere hardcode-tray,\n    pues éste necesita usar 'sudo' para poder hacer los cambios\n    correspondientes en el sistema.\n\n    Ejecuta como root lo siguiente:${reset}\n\n${bold}    gpasswd -a ${USER} wheel${reset}\n\n${red}${bold}    Luego ejecuta como root 'visudo' y descomenta la línea correspondiente a:${reset}\n\n    ${bold}%wheel        ALL=(ALL)       ALL\n${reset}\n\n    ${red}${bold}O bien, si prefieres usar 'sudo' sin contraseña, descomenta en su lugar\n    la línea correspondiente a:${reset}\n\n    ${bold}%wheel        ALL=(ALL)       NOPASSWD: ALL\n${reset}"
    exit 1
fi

# Validamos que se proporcione un argumento.
if [ "$#" -eq 0 ]; then
    printf "%b\n" "${green}${bold}  * Utilice el nombre de un tema como argumento."
    printf "%b\n" "${green}${bold}  * Uso: tema-xfce4.sh [Tema]"
    printf "%b\n" " "
    printf "%b\n" "${blue}${bold}Temas disponibles en ALDOS:${purple}${bold}"
    printf "%b\n" " ALDOS ALDOSDarker Adwaita AdwaitaDark Amber AmberCircle Andromeda Ant Arc"
    printf "%b\n" " ArcDarker BlueSky Bubble Chicago95 Cloudy Colloid ColloidDark Dracula"
    printf "%b\n" " DraculaCandy Fluent FluentDark Graphite Greybird Juno Kimi Lavanda"
    printf "%b\n" " Layan Jasper JasperLight Magnetic Midnight MojaveDark MojaveLight Nordic"
    printf "%b\n" " NordicPolar Numix NumixCircle NumixSquare Otis Plano PlanoLight Qogir"
    printf "%b\n" " QogirDark QogirLight Redmond98 Redmond10 Redmond7 RedmondXP ShadesOfPurple"
    printf "%b\n" " Snow Space Sweet Vimix VimixDark WhiteSurDark WhiteSurLight"
    printf "%b\n" " "
    printf "%b\n" "${green}${bold}Ejemplos:"
    printf "%b\n" "${white}${bold}  tema-xfce4.sh ${purple}${bold}ALDOS"
    printf "%b\n" " "
    printf "%b\n" "${white}${bold}  tema-xfce4.sh ${purple}${bold}Amber"
    printf "%b\n" " "
    printf "%b\n" "${white}${bold}  tema-xfce4.sh ${purple}${bold}Arc"
    printf "%b\n" " "
    printf "%b\n" "${blue}${bold}* Use '${white}${bold}demo${blue}${bold}' como argumento para presentar todos los temas c/u por 20 seg."
    printf "%b\n" "${blue}${bold}  (Al final establecerá ${purple}${bold}ALDOS${blue}${bold} como tema.) "
    printf "%b\n" " "
    printf "%b" "${green}${bold}* Refrescando caché de yum con pkcon y sudo..."
    sudo -k
    pkcon refresh > /dev/null 2>&1
    printf "%b\n" "${green}${bold} Hecho.${reset} "
    exit 1
fi

ALDOS() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        nordic-cursor-theme arc-theme tela-icon-theme-nord; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            nordic-cursor-theme arc-theme tela-icon-theme-nord
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Arc
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Nordic-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-nord"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Arc
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Nordic-cursors"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Arc"
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-nord"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Arc"
        gsettings set org.cinnamon.theme name "Arc"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Nordic-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Arc"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-nord"
        gsettings set org.gnome.desktop.wm.preferences theme "Arc"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Tela-nord"
        gsettings set org.mate.interface gtk-theme "Arc"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Nordic-cursors"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "Arc"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'ALDOS' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ALDOS' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

ALDOSDarker() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme tela-icon-theme-nord; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-cursor-theme arc-theme tela-icon-theme-nord
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Arc-Darker"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Nordic-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-nord"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Arc-Darker"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Nordic-cursors"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Arc"
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-nord"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Arc-Darker"
        gsettings set org.cinnamon.theme name "Arc"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Nordic-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Arc-Darker"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-nord"
        gsettings set org.gnome.desktop.wm.preferences theme "Arc-Darker"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'ALDOSDark' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ALDOSDark' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

ALDOSDark() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme tela-icon-theme-nord; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-cursor-theme arc-theme tela-icon-theme-nord
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Arc-Dark"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Nordic-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-nord-dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Arc-Dark"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Nordic-cursors"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Arc-Dark"
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-nord"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Arc-Dark"
        gsettings set org.cinnamon.theme name "Arc-Dark"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Nordic-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-nord-dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Arc-Dark"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'ALDOSDark' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ALDOSDark' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

BlueSky() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme bluesky-gtk-theme tela-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            adwaita-cursor-theme bluesky-gtk-theme tela-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s BlueSky
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s BlueSky
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita"
        gsettings set org.cinnamon.desktop.interface gtk-theme "BlueSky"
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela"
        gsettings set org.cinnamon.desktop.wm.preferences theme "BlueSky"
        gsettings set org.cinnamon.theme name "BlueSky"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "BlueSky"
        gsettings set org.gnome.desktop.interface icon-theme "Tela"
        gsettings set org.gnome.desktop.wm.preferences theme "BlueSky"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Tela"
        gsettings set org.mate.interface gtk-theme "BlueSky"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Adwaita"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "BlueSky"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'BlueSky' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'BlueSky' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Midnight() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme midnight-gtk-theme tela-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            adwaita-cursor-theme midnight-gtk-theme tela-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Midnight
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Midnight
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Midnight"
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-dark"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Midnight"
        gsettings set org.cinnamon.theme name "Midnight"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Midnight"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Midnight"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Tela-dark"
        gsettings set org.mate.interface gtk-theme "Midnight"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Adwaita"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "Midnight"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Midnight' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Midnight' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Cloudy() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        nordic-cursor-theme cloudy-gtk-theme tela-icon-theme-nord; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            nordic-cursor-theme cloudy-gtk-theme tela-icon-theme-nord
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Cloudy
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Nordic-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-nord"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Cloudy
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Nordic-cursors"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Cloudy"
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-nord"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Cloudy"
        gsettings set org.cinnamon.theme name "Cloudy"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Nordic-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Cloudy"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-nord"
        gsettings set org.gnome.desktop.wm.preferences theme "Cloudy"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Tela-nord"
        gsettings set org.mate.interface gtk-theme "Cloudy"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Nordic-cursors"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "Cloudy"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Cloudy' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Cloudy' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Bubble() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme bubble-gtk-theme tela-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            adwaita-cursor-theme bubble-gtk-theme tela-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Bubble
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Bubble
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Bubble"
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Bubble"
        gsettings set org.cinnamon.theme name "Bubble"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Bubble"
        gsettings set org.gnome.desktop.interface icon-theme "Tela"
        gsettings set org.gnome.desktop.wm.preferences theme "Bubble"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Tela"
        gsettings set org.mate.interface gtk-theme "Bubble"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Adwaita"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "Bubble"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Bubble' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Bubble' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Lavanda() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        fluent-cursor-theme bluesky-gtk-theme papirus-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            fluent-cursor-theme bluesky-gtk-theme papirus-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Lavanda
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Fluent-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-circle"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Lavanda
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Fluent-cursors"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Lavanda"
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-circle"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Lavanda"
        gsettings set org.cinnamon.theme name "Arc"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Fluent-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Lavanda"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-circle"
        gsettings set org.gnome.desktop.wm.preferences theme "Lavanda"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Tela-circle"
        gsettings set org.mate.interface gtk-theme "Lavanda"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Fluent-cursors"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "Lavanda"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Lavanda' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Lavanda' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

ShadesOfPurple() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        layan-cursor-theme shades-of-purple-gtk-theme candy-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            layan-cursor-theme shades-of-purple-gtk-theme candy-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Shades-of-purple"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Layan-white-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Candy
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Shades-of-purple"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Layan-white-cursors"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Shades-of-purple"
        gsettings set org.cinnamon.desktop.interface icon-theme "Candy"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Shades-of-purple"
        gsettings set org.cinnamon.theme name "Shades-of-purple"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Layan-white-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Shades-of-purple"
        gsettings set org.gnome.desktop.interface icon-theme "Candy"
        gsettings set org.gnome.desktop.wm.preferences theme "Shades-of-purple"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Candy"
        gsettings set org.mate.interface gtk-theme "Shades-of-purple"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Layan-white-cursors"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "Shades-of-purple"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Shades-of-purple' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Shades-of-purple' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Plano() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme plano-theme tela-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-cursor-theme plano-theme tela-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Plano-dark-titlebar"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Plano-dark-titlebar"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Numix"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Plano-dark-titlebar"
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Plano"
        gsettings set org.cinnamon.theme name "Adwaita"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix"
        gsettings set org.gnome.desktop.interface gtk-theme "Plano-dark-titlebar"
        gsettings set org.gnome.desktop.interface icon-theme "Tela"
        gsettings set org.gnome.desktop.wm.preferences theme "Plano"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Plano' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Plano' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

PlanoLight() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme plano-theme tela-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-cursor-theme plano-theme tela-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Plano
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Plano
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix"
        gsettings set org.gnome.desktop.interface gtk-theme "Plano"
        gsettings set org.gnome.desktop.interface icon-theme "Numix"
        gsettings set org.gnome.desktop.wm.preferences theme "Plano"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'PlanoLight' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'PlanoLight' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Amber() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-icon-theme numix-cursor-theme amber-theme tela-icon-theme-black; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-icon-theme numix-cursor-theme amber-theme tela-icon-theme-black
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Amber
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Numix
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Amber
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix"
        gsettings set org.gnome.desktop.interface gtk-theme "Amber"
        gsettings set org.gnome.desktop.interface icon-theme "Numix"
        gsettings set org.gnome.desktop.wm.preferences theme "Amber"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Amber' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Amber' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

AmberCircle() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme amber-theme numix-icon-theme-circle; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-cursor-theme amber-theme numix-icon-theme-circle
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Amber
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Numix-Circle"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Amber
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix"
        gsettings set org.gnome.desktop.interface gtk-theme "Amber"
        gsettings set org.gnome.desktop.interface icon-theme "Numix-Circle"
        gsettings set org.gnome.desktop.wm.preferences theme "Amber"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Amber' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Amber' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Arc() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        arc-theme papirus-icon-theme adwaita-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-cursor-theme arc-theme papirus-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Arc
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Arc
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Arc"
        gsettings set org.gnome.desktop.interface icon-theme "Papirus"
        gsettings set org.gnome.desktop.wm.preferences theme "Arc"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Arc' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Arc' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

ArcDarker() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        arc-theme papirus-icon-theme adwaita-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            arc-theme papirus-icon-theme adwaita-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Arc-Darker"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Arc-Darker"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Arc-Darker"
        gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Arc-Darker"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'ArcDarker' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ArcDarker' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

ArcDark() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        arc-theme papirus-icon-theme adwaita-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-cursor-theme arc-theme papirus-icon-theme adwaita-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Arc-Dark"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Papirus-Dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Arc-Dark"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Arc-Dark"
        gsettings set org.gnome.desktop.interface icon-theme "Papirus-Dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Arc-Dark"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'ArcDark' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ArcDark' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Numix() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme numix-gtk-theme numix-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-cursor-theme numix-gtk-theme numix-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Numix
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Numix
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Numix
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix"
        gsettings set org.gnome.desktop.interface gtk-theme "Numix"
        gsettings set org.gnome.desktop.interface icon-theme "Numix"
        gsettings set org.gnome.desktop.wm.preferences theme "Numix"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Numix' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Numix' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

NumixCircle() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme numix-gtk-theme numix-icon-theme-circle; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-cursor-theme numix-gtk-theme numix-icon-theme-circle
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Numix
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Numix-Circle"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Numix
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix"
        gsettings set org.gnome.desktop.interface gtk-theme "Numix"
        gsettings set org.gnome.desktop.interface icon-theme "Numix-Circle"
        gsettings set org.gnome.desktop.wm.preferences theme "Numix"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'NumixCircle' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'NumixCircle' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

NumixSquare() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme numix-gtk-theme numix-icon-theme-square; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-cursor-theme numix-gtk-theme numix-icon-theme-square
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Numix
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Numix-Square"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Numix
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Numix"
        gsettings set org.gnome.desktop.interface gtk-theme "Numix"
        gsettings set org.gnome.desktop.interface icon-theme "Numix-Square"
        gsettings set org.gnome.desktop.wm.preferences theme "Numix"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'NumixSquare' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'NumixSquare' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Greybird() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        dmz-cursor-themes greybird-light-theme greybird-xfwm4-theme elementary-xfce-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            dmz-cursor-themes greybird-light-theme greybird-xfwm4-theme elementary-xfce-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Greybird
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "DMZ-Black"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "elementary-xfce-dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Greybird
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "DMZ-Black"
        gsettings set org.gnome.desktop.interface gtk-theme "Greybird"
        gsettings set org.gnome.desktop.interface icon-theme "elementary-xfce-dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Greybird"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Grebird' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Grebird' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Ant() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        ant-gtk-theme boston-icon-theme adwaita-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            ant-gtk-theme boston-icon-theme adwaita-cursor-theme 
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Ant
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Boston
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Ant
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Ant"
        gsettings set org.gnome.desktop.interface icon-theme "Boston"
        gsettings set org.gnome.desktop.wm.preferences theme "Ant"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Ant' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Ant' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Kimi() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        kimi-gtk-theme tela-icon-theme-purple adwaita-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            kimi-gtk-theme tela-icon-theme-purple adwaita-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Kimi
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-purple"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Kimi
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Kimi"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-purple"
        gsettings set org.gnome.desktop.wm.preferences theme "Kimi"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Kimi' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Kimi' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Juno() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        juno-gtk-theme zafiro-icon-theme adwaita-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            juno-gtk-theme zafiro-icon-theme adwaita-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Juno
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Zafiro-icons"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Juno
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Juno"
        gsettings set org.gnome.desktop.interface icon-theme "Zafiro-icons"
        gsettings set org.gnome.desktop.wm.preferences theme "Juno"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Juno' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Juno' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Otis() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        otis-gtk-theme candy-icon-theme adwaita-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            otis-gtk-theme candy-icon-theme adwaita-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Otis
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Candy
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Otis
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Otis"
        gsettings set org.gnome.desktop.interface icon-theme "Candy"
        gsettings set org.gnome.desktop.wm.preferences theme "Otis"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Otis"
        gsettings set org.cinnamon.desktop.interface icon-theme "Candy"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Otis"
        gsettings set org.cinnamon.theme name "Otis"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Candy"
        gsettings set org.mate.interface gtk-theme "Otis"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Adwaita"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "Otis"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Otis' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Otis' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Andromeda() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        andromeda-gtk-theme tela-icon-theme-nord nordzy-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            andromeda-gtk-theme tela-icon-theme-nord nordzy-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Andromeda
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Nordzy-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-nord"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Andromeda
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Nordzy-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Andromeda"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-nord"
        gsettings set org.gnome.desktop.wm.preferences theme "Andromeda"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Nordzy-cursors"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Andromeda"
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-nord"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Andromeda"
        gsettings set org.cinnamon.theme name "Andromeda"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Tela-nord"
        gsettings set org.mate.interface gtk-theme "Nordzy-cursors"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Nordzy-cursors"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "Andromeda"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Andromeda' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Andromeda' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Snow() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        snow-gtk-theme boston-icon-theme adwaita-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            snow-gtk-theme boston-icon-theme adwaita-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Snow
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Boston
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Snow
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Snow"
        gsettings set org.gnome.desktop.interface icon-theme "Boston"
        gsettings set org.gnome.desktop.wm.preferences theme "Snow"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Snow' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Snow' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Sweet() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        sweet-gtk-theme boston-icon-theme adwaita-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            sweet-gtk-theme boston-icon-theme adwaita-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Sweet
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Boston
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Sweet
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Sweet"
        gsettings set org.gnome.desktop.interface icon-theme "Boston"
        gsettings set org.gnome.desktop.wm.preferences theme "Sweet"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Sweet' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Sweet' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Space() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        space-gtk-theme boston-icon-theme adwaita-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            space-gtk-theme boston-icon-theme adwaita-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Space
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Boston
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Space
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Space"
        gsettings set org.gnome.desktop.interface icon-theme "Boston"
        gsettings set org.gnome.desktop.wm.preferences theme "Space"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Adwaita"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Space"
        gsettings set org.cinnamon.desktop.interface icon-theme "Boston"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Space"
        gsettings set org.cinnamon.theme name "Space"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Boston"
        gsettings set org.mate.interface gtk-theme "Space"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Adwaita"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "Space"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Space' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Space' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Dracula() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        dracula-gtk-theme tela-circle-dracula-icon-theme dracula-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            dracula-gtk-theme tela-circle-dracula-icon-theme dracula-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Dracula
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Dracula-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-circle-dracula-dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Dracula
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Dracula-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-dracula-dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Dracula"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Tela-circle-dracula-dark"
        gsettings set org.mate.interface gtk-theme "Dracula"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Dracula-cursors"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "Dracula"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Dracula' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Dracula' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

DraculaCandy() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        dracula-gtk-theme candy-icon-theme dracula-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            dracula-gtk-theme candy-icon-theme dracula-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Dracula
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Dracula-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Candy
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Dracula
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Dracula-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Dracula"
        gsettings set org.gnome.desktop.interface icon-theme "Candy"
        gsettings set org.gnome.desktop.wm.preferences theme "Dracula"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Dracula' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Dracula' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Magnetic() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        magnetic-gtk-theme tela-circle-icon-theme fluent-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            magnetic-gtk-theme tela-circle-icon-theme fluent-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Magnetic
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Fluent-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-circle"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Magnetic
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Fluent-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Magnetic"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-circle"
        gsettings set org.gnome.desktop.wm.preferences theme "Magnetic"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Fluent-cursors"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Magnetic"
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-circle"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Magnetic"
        gsettings set org.cinnamon.theme name "Magnetic"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Tela-circle"
        gsettings set org.mate.interface gtk-theme "Magnetic"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Fluent-cursors"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "Magnetic"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Magnetic' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Magnetic' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Jasper() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        jasper-gtk-theme fluent-icon-theme-teal fluent-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            jasper-gtk-theme fluent-icon-theme-teal fluent-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Jasper-Dark"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Fluent-dark-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Fluent-teal-dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Jasper-Dark"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Fluent-dark-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Jasper-Dark"
        gsettings set org.gnome.desktop.interface icon-theme "Fluent-teal-dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Jasper-Dark"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Jasper' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Jasper' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

JasperLight() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        jasper-gtk-theme fluent-icon-theme-teal fluent-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            jasper-gtk-theme fluent-icon-theme-teal fluent-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Jasper-Light"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Fluent-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Fluent-teal"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Jasper-Light"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Fluent-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Jasper-Light"
        gsettings set org.gnome.desktop.interface icon-theme "Fluent-teal"
        gsettings set org.gnome.desktop.wm.preferences theme "Jasper-Light"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'JasperLight' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'JasperLight' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Graphite() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        graphite-gtk-theme tela-circle-black-icon-theme graphite-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            graphite-gtk-theme tela-circle-black-icon-theme graphite-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Graphite-Dark"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Graphite-dark-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-circle-black-dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Graphite-Dark"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Graphite-dark-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Graphite-Dark"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-black-dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Graphite-Dark"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Graphite' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Graphite' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

GraphiteLight() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        graphite-gtk-theme tela-circle-black-icon-theme graphite-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            graphite-gtk-theme tela-circle-black-icon-theme graphite-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Graphite-Light"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Graphite-light-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-circle-black"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Graphite-Light"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Graphite-light-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Graphite-Light"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-black"
        gsettings set org.gnome.desktop.wm.preferences theme "Graphite-Light"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'GraphiteLight' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'GraphiteLight' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Colloid() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        colloid-gtk-theme colloid-icon-theme colloid-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            colloid-gtk-theme colloid-icon-theme colloid-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Colloid
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Colloid-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Colloid-Dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Colloid
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Colloid-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Colloid"
        gsettings set org.gnome.desktop.interface icon-theme "Colloid-Dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Colloid"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Colloid' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Colloid' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

ColloidDark() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        colloid-gtk-theme colloid-icon-theme colloid-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            colloid-gtk-theme colloid-icon-theme colloid-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Colloid-Dark"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Colloid-dark-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Colloid-Dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Colloid-Dark"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Colloid-dark-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Colloid-Dark"
        gsettings set org.gnome.desktop.interface icon-theme "Colloid-Dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Colloid-Dark"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'ColloidDark' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ColloidDark' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

ColloidLight() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        colloid-gtk-theme colloid-icon-theme colloid-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            colloid-gtk-theme colloid-icon-theme colloid-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Colloid-Light"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Colloid-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Colloid-Light"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Colloid-Light"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Colloid-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Colloid-Light"
        gsettings set org.gnome.desktop.interface icon-theme "Colloid-Light"
        gsettings set org.gnome.desktop.wm.preferences theme "Colloid-Light"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'ColloidLight' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ColloidLight' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Layan() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme layan-gtk-theme tela-icon-theme layan-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-cursor-theme layan-gtk-theme tela-icon-theme layan-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Layan
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Layan-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Layan
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Layan-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Layan"
        gsettings set org.gnome.desktop.interface icon-theme "Tela"
        gsettings set org.gnome.desktop.wm.preferences theme "Layan"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Layan' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Layan' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Nordic() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme nordic-gtk-theme tela-icon-theme-nord nordic-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-cursor-theme nordic-gtk-theme tela-icon-theme-nord nordic-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Nordic
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Nordic-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-nord"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Nordic
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Nordic-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Nordic"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-nord"
        gsettings set org.gnome.desktop.wm.preferences theme "Nordic"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Nordic-cursors"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Nordic"
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-nord"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Nordic"
        gsettings set org.cinnamon.theme name "Nordic"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Tela-nord"
        gsettings set org.mate.interface gtk-theme "Nordic"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Nordic-cursors"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "Nordic"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Nordic' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Nordic' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

NordicPolar() {
    if ! rpm -q --quiet \
        numix-cursor-theme nordic-polar-gtk-theme tela-icon-theme-nord nordic-cursor-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            numix-cursor-theme nordic-polar-gtk-theme tela-icon-theme-nord nordic-cursor-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Nordic-Polar"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Nordic-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-nord"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Nordic-Polar"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Nordic-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Nordic-Polar"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-nord"
        gsettings set org.gnome.desktop.wm.preferences theme "Nordic-Polar"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.cinnamon.desktop.interface.gschema.xml" ]; then
        gsettings set org.cinnamon.desktop.interface cursor-theme "Nordic-cursors"
        gsettings set org.cinnamon.desktop.interface gtk-theme "Nordic-Polar"
        gsettings set org.cinnamon.desktop.interface icon-theme "Tela-nord"
        gsettings set org.cinnamon.desktop.wm.preferences theme "Nordic-Polar"
        gsettings set org.cinnamon.theme name "Nordic-Polar"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.interface.gschema.xml" ]; then
        gsettings set org.mate.interface icon-theme "Tela-nord"
        gsettings set org.mate.interface gtk-theme "Nordic-Polar"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.peripherals-mouse.gschema.xml" ]; then
        gsettings set org.mate.peripherals-mouse cursor-theme "Nordic-cursors"
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.mate.marco.gschema.xml" ]; then
        gsettings set org.mate.Marco.general theme "Nordic-Polar"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'NordicPolar' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'NordicPolar' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Adwaita() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme gnome-themes-extra adwaita-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            adwaita-cursor-theme gnome-themes-extra adwaita-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Default
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Adwaita"
        gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
        gsettings set org.gnome.desktop.wm.preferences theme "Adwaita"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Adwaita' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Adwaita' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

AdwaitaDark() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme gnome-themes-extra adwaita-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            adwaita-cursor-theme gnome-themes-extra adwaita-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Default
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Adwaita-dark"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "Adwaita-dark"
        gsettings set org.gnome.desktop.interface icon-theme "Adwaita"
        gsettings set org.gnome.desktop.wm.preferences theme "Adwaita"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'AdwaitaDark' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'AdwaitaDark' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Vimix() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        vimix-cursor-theme vimix-gtk-theme vimix-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            vimix-cursor-theme vimix-gtk-theme vimix-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Vimix
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Vimix-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Vimix
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Vimix
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Vimix-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Vimix"
        gsettings set org.gnome.desktop.interface icon-theme "Vimix"
        gsettings set org.gnome.desktop.wm.preferences theme "Vimix"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Vimix' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Vimix' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

VimixDark() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        vimix-gtk-theme vimix-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            vimix-gtk-theme vimix-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Vimix-dark"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Vimix-white-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Vimix-dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Vimix-dark"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Vimix-white-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Vimix-dark"
        gsettings set org.gnome.desktop.interface icon-theme "Vimix-dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Vimix-dark"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'VimixDark' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'VimixDark' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

MojaveLight() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        mojave-gtk-theme mcmojave-cursor-theme mcmojave-circle-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            mojave-gtk-theme mcmojave-cursor-theme mcmojave-circle-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Mojave-Light"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "McMojave-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "McMojave-circle"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Mojave-Light"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "McMojave-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Mojave-Light"
        gsettings set org.gnome.desktop.interface icon-theme "McMojave-circle"
        gsettings set org.gnome.desktop.wm.preferences theme "Mojave-Light"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'MojaveLight' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'MojaveLight' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

MojaveDark() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        mojave-gtk-theme mcmojave-cursor-theme mcmojave-circle-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            mojave-gtk-theme mcmojave-cursor-theme mcmojave-circle-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Mojave-Dark"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "McMojave-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "McMojave-circle-dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Mojave-Dark"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "McMojave-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Mojave-Dark"
        gsettings set org.gnome.desktop.interface icon-theme "McMojave-circle-dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Mojave-Dark"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'MojaveDark' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'MojaveDark' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

WhiteSurLight() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        whitesur-gtk-theme whitesur-cursor-theme whitesur-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            whitesur-gtk-theme whitesur-cursor-theme whitesur-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "WhiteSur-Light"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "WhiteSur-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s WhiteSur
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "WhiteSur-Light"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Light"
        gsettings set org.gnome.desktop.interface icon-theme "WhiteSur"
        gsettings set org.gnome.desktop.wm.preferences theme "WhiteSur-Light"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'WhiteSurLight' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'WhiteSurLight' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

WhiteSurDark() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        whitesur-gtk-theme whitesur-cursor-theme whitesur-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            whitesur-gtk-theme whitesur-cursor-theme whitesur-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "WhiteSur-Dark"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "WhiteSur-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "WhiteSur-dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "WhiteSur-Dark"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "WhiteSur-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "WhiteSur-Dark"
        gsettings set org.gnome.desktop.interface icon-theme "WhiteSur-dark"
        gsettings set org.gnome.desktop.wm.preferences theme "WhiteSur-Dark"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'WhiteSurDark' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'WhiteSurDark' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

OrchisDark() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        orchis-gtk-theme tela-circle-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            orchis-gtk-theme tela-circle-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Orchis-dark"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Vimix-dark"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Tela-circle-dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Orchis-dark"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Vimix-dark"
        gsettings set org.gnome.desktop.interface gtk-theme "Orchis-dark"
        gsettings set org.gnome.desktop.interface icon-theme "Tela-circle-dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Orchis-dark"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'OrchisDark' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'OrchisDark' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Qogir() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        qogir-gtk-theme qogir-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            qogir-gtk-theme qogir-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Qogir
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Qogir
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Qogir
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Qogir
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Qogir"
        gsettings set org.gnome.desktop.interface gtk-theme "Qogir"
        gsettings set org.gnome.desktop.interface icon-theme "Qogir"
        gsettings set org.gnome.desktop.wm.preferences theme "Qogir"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Qogir' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Qogir' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

QogirDark() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        qogir-gtk-theme qogir-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            qogir-gtk-theme qogir-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Qogir-Dark"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Qogir-Dark"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Qogir-Dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Qogir-Dark"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Qogir-Dark"
        gsettings set org.gnome.desktop.interface gtk-theme "Qogir-Dark"
        gsettings set org.gnome.desktop.interface icon-theme "Qogir-Dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Qogir-Dark"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'QogirDark' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'QogirDark' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

QogirLight() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        qogir-gtk-theme qogir-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            qogir-gtk-theme qogir-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Qogir-Light"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Qogir
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Qogir-Light"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Qogir-Light"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Qogir"
        gsettings set org.gnome.desktop.interface gtk-theme "Qogir-Light"
        gsettings set org.gnome.desktop.interface icon-theme "Qogit-Light"
        gsettings set org.gnome.desktop.wm.preferences theme "Qogit-Light"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'QogirLight' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'QogirLight' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Fluent() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        fluent-gtk-theme fluent-cursor-theme fluent-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            fluent-gtk-theme fluent-cursor-theme fluent-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Fluent
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Fluent-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Fluent-dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Fluent
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Fluent-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Fluent"
        gsettings set org.gnome.desktop.interface icon-theme "Fluent-dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Fluent"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Fluent' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'fluent' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

FluentDark() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        fluent-gtk-theme fluent-cursor-theme fluent-icon-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            fluent-gtk-theme fluent-cursor-theme fluent-icon-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "Fluent-Dark"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Fluent-dark-cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Fluent-dark"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "Fluent-Dark"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Fluent-dark-cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Fluent-Dark"
        gsettings set org.gnome.desktop.interface icon-theme "Fluent-dark"
        gsettings set org.gnome.desktop.wm.preferences theme "Fluent-Dark"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'FluentDark' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'FluentDark' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Chicago95() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        chicago95-cursor-theme chicago95-gtk-theme chicago95-icon-theme \
        chicago95-sound-theme chicago95-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            chicago95-cursor-theme chicago95-gtk-theme chicago95-icon-theme \
            chicago95-sound-theme chicago95-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Chicago95
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Chicago95_Animated_Hourglass_Cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Chicago95
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Chicago95
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Chicago95
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarTreePane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Chicago95_Animated_Hourglass_Cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Chicago95"
        gsettings set org.gnome.desktop.interface icon-theme "Chicago95"
        gsettings set org.gnome.desktop.wm.preferences theme "Chicago95"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Chicago95' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Chicago95' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Redmond98() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        chicago95-cursor-theme chicago95-gtk-theme redmond98se-icon-theme \
        chicago95-sound-theme chicago95-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            chicago95-cursor-theme chicago95-gtk-theme redmond98se-icon-theme \
            chicago95-sound-theme chicago95-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Chicago95
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "Chicago95_Animated_Hourglass_Cursors"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s "Redmond98SE"
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Chicago95
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Chicago95
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarTreePane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Chicago95_Animated_Hourglass_Cursors"
        gsettings set org.gnome.desktop.interface gtk-theme "Chicago95"
        gsettings set org.gnome.desktop.interface icon-theme "Redmond98SE"
        gsettings set org.gnome.desktop.wm.preferences theme "Chicago95"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Chicago95' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Chicago95' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

RedmondXP() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        redmondxp-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            redmondxp-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s "RedmondXP_Luna"
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "DMZ-White"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s RedmondXP
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s "RedmondXP_Luna"
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarTreePane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "DMZ-White"
        gsettings set org.gnome.desktop.interface gtk-theme "RedmondXP"
        gsettings set org.gnome.desktop.interface icon-theme "RedmondXP"
        gsettings set org.gnome.desktop.wm.preferences theme "RedmondXP"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'RedmondXP' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'RedmondXP' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Redmond7() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        redmond7-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            redmond7-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Redmond7
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "DMZ-White"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Redmond7
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Redmond7
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "DMZ-White"
        gsettings set org.gnome.desktop.interface gtk-theme "Redmond7"
        gsettings set org.gnome.desktop.interface icon-theme "Redmond7"
        gsettings set org.gnome.desktop.wm.preferences theme "Redmond7"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Redmond7' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Redmond7' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

Redmond10() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        redmond10-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            redmond10-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s Redmond10
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s "DMZ-White"
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Redmond10
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Redmond10
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "DMZ-White"
        gsettings set org.gnome.desktop.interface gtk-theme "Redmond10"
        gsettings set org.gnome.desktop.interface icon-theme "Redmond10"
        gsettings set org.gnome.desktop.wm.preferences theme "Redmond10"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'Redmond10' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Redmond10' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

LaStrange() {
    if ! rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme lastrange-icon-theme lastrange-gtk-theme; then
        pkcon -y install \
            hardcode-tray sound-theme-smooth \
            adwaita-cursor-theme lastrange-icon-theme lastrange-gtk-theme
    fi

    if [ -e "/etc/xdg/xfce4/xfconf/xfce-perchannel-xml/xsettings.xml" ]; then
        xfconf-query -t string -c xfwm4 -p /general/theme -s LaStrange
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s LaStrange
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s LaStrange
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarTreePane
    fi

    if [ -e "/usr/share/glib-2.0/schemas/org.gnome.desktop.interface.gschema.xml" ]; then
        gsettings set org.gnome.desktop.interface cursor-theme "Adwaita"
        gsettings set org.gnome.desktop.interface gtk-theme "LaStrange"
        gsettings set org.gnome.desktop.interface icon-theme "LaStrange"
        gsettings set org.gnome.desktop.wm.preferences theme "LaStrange"
    fi

    printf "%b" "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..."
    if sudo hardcode-tray --apply > /dev/null; then
        printf "%b\n" "${white}${bold} Hecho."
        sleep 1
        printf "%b\n" "${white}${bold}Tema 'LaStrange' establecido.${reset}"
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'LaStrange' establecido"
    else
        printf "\n%b\n" "${red}${bold}Error aplicando hardcode-tray.${reset}" >&2
        return 1
    fi
}

demo() {
    for TESTTHEME in \
        ALDOS ALDOSDarker Adwaita AdwaitaDark Amber AmberCircle Andromeda Ant Arc \
        ArcDarker BlueSky Bubble Chicago95 Cloudy Colloid ColloidDark Dracula \
        DraculaCandy Fluent FluentDark Graphite Greybird Juno Kimi Lavanda \
        Layan Jasper JasperLight Magnetic Midnight MojaveDark MojaveLight Nordic \
        NordicPolar Numix NumixCircle NumixSquare Otis Plano PlanoLight Qogir \
        QogirDark QogirLight Redmond98 Redmond10 Redmond7 RedmondXP ShadesOfPurple \
        Snow Space Sweet Vimix VimixDark WhiteSurDark WhiteSurLight ALDOS
    do
        "${TESTTHEME}"
        sleep 20
    done
}

# Ejecutar la función solicitada
"$1"
