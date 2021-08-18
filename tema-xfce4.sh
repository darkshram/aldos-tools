#!/bin/bash
# Copyright 2021 Joel Barrios <darkshram@gmail.com>

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

# Validamos que se proporcione un argumento.
if [ $# -eq 0 ]; then
    echo -e "${green}${bold} "
    echo -e "${red}${bold}  * Se requiere el nombre de un tema como argumento."
    echo -e "${green}${bold}  * Uso: $0 Tema"
    echo -e " "
    echo -e "${blue}${bold}  Temas disponibles:${purple}${bold}"
    echo -e "   ALDOS ALDOSDarker Adwaita Amber AmberCircle Arc ArcDarker Chicago95"
    echo -e "   Dracula Fluent FluentDark Greybird LaStrange Layan Materia MateriaDark"
    echo -e "   MojaveDark MojaveLight Nordic NordicPolar Numix NumixCircle NumixSquare"
    echo -e "   Plano PlanoLight Qogir QogirDark QogirLight Redmond10 Redmond7 RedmondXP"
    echo -e "   Vimix VimixDark WhiteSurDark WhiteSurLight"
    echo -e " "
    echo -e "${green}${bold}  Ejemplos:"
    echo -e "${white}${bold}  $0 ${purple}${bold}ALDOS"
    echo -e " "
    echo -e "${white}${bold}  $0 ${purple}${bold}Amber"
    echo -e " "
    echo -e "${white}${bold}  $0 ${purple}${bold}Arc"
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
        numix-cursor-theme arc-theme tela-icon-theme-black || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme tela-icon-theme-black
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme tela-icon-theme-black && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Arc && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-black-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Arc && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'ALDOS' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ALDOS' establecido"
}

function ALDOSDarker() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme tela-black-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme tela-black-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme tela-black-icon-theme && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Arc-Darker && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-black-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Arc && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'ALDOSDark' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ALDOSDark' establecido"
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Plano-dark-titlebar && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Plano-dark-titlebar && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Plano && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Plano && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'PlanoLight' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'PlanoLight' establecido"
}

function Amber() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme amber-theme tela-black-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme amber-theme tela-black-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme amber-theme tela-black-icon-theme && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Amber && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-black && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Amber && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Amber' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Amber' establecido"
}

function AmberCircle() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme amber-theme tela-circle-black || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme amber-theme tela-circle-black
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme amber-theme tela-circle-black && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Amber && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-circle-black && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Amber && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Amber' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Amber' establecido"
}

function Arc() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme papirus-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme papirus-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme papirus-icon-theme && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Arc && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Arc && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Arc' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Arc' establecido"
}

function ArcDarker() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme papirus-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme papirus-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme papirus-icon-theme && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Arc-Darker && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Arc-Darker && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'ArcDarker' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'ArcDarker' establecido"
}

function ArcDark() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme papirus-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme papirus-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme arc-theme papirus-icon-theme && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Arc-Dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus-Dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Arc-Dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Numix && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Numix && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Numix-Circle && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Numix && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Numix-Square && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'NumixSquare' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'NumixSquare' establecido"
}

function Greybird() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme greybird-light-theme adwaita-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme greybird-light-theme adwaita-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme greybird-light-theme adwaita-icon-theme && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Greybird && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Greybird && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Grebird' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Grebird' establecido"
}


function Dracula() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme dracula-gtk-theme dracula-icon-theme oreo-dracula-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme dracula-gtk-theme dracula-icon-theme oreo-dracula-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme dracula-gtk-theme dracula-icon-theme oreo-dracula-cursor-theme && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Dracula && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Oreo-Dracula-dark-purple && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Dracula && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Dracula && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Dracula' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Dracula' establecido"
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Layan && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Layan-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Layan && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Layan' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Layan' establecido"
}

function Nordic() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme nordic-gtk-theme nordzy-icon-theme nordzy-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme nordic-gtk-theme nordzy-icon-theme nordzy-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme nordic-gtk-theme nordzy-icon-theme nordzy-cursor-theme && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Nordic && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Nordzy-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Nordzy-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Nordic && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Nordic' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Nordic' establecido"
}

function NordicPolar() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme nordic-polar-gtk-theme zafiro-icon-theme nordzy-cursor-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme nordic-polar-gtk-theme zafiro-icon-theme nordzy-cursor-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme nordic-polar-gtk-theme zafiro-icon-theme nordzy-cursor-theme && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Nordic-Polar && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Nordzy-white-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Zafiro-icons && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Nordic-Polar && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'NordicPolar' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'NordicPolar' establecido"
}

function Adwaita() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme gnome-themes-extra greybird-light-theme adwaita-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme gnome-themes-extra greybird-light-theme adwaita-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        adwaita-cursor-theme gnome-themes-extra greybird-light-theme adwaita-icon-theme && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Greybird && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Greybird && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Adwaita' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Adwaita' establecido"
}

function Materia() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme materia-gtk-theme papirus-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme materia-gtk-theme papirus-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme materia-gtk-theme papirus-icon-theme && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Materia-compact && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Materia-compact && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'Materia' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'Materia' establecido"
}

function MateriaDark() {
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme materia-gtk-theme papirus-icon-theme || \
        pkcon -y install \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme materia-gtk-theme papirus-icon-theme
    rpm -q --quiet \
        hardcode-tray sound-theme-smooth \
        numix-cursor-theme materia-gtk-theme papirus-icon-theme && \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Materia-dark-compact && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Numix && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Papirus-Dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Materia-dark-compact && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Vimix && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Vimix-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Vimix && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Vimix && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Vimix-dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Vimix-white-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Vimix-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Vimix-dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Mojave-light && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s McMojave-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s McMojave-circle && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Mojave-light && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Mojave-dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s McMojave-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s McMojave-circle-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Mojave-dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s WhiteSur-light && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s WhiteSur-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s WhiteSur && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s WhiteSur-light && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s WhiteSur-dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s WhiteSur-cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s WhiteSur-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s WhiteSur-dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        orchis-gtk-theme tela-circle-icon-theme || \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Orchis-dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Vimix-dark && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Tela-circle-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Orchis-dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        qogir-gtk-theme qogir-icon-theme || \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Qogir && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Qogir && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Qogir && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Qogir && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        qogir-gtk-theme qogir-icon-theme || \
        xfconf-query -t string -c xfwm4 -p /general/theme -s Qogir-dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Qogir-dark && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Qogir-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Qogir-dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Qogir-light && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Qogir && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Qogir-light && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Qogir-light && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Fluent && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Fluent && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Fluent && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Fluent && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Fluent-dark && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Fluent-dark && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Fluent-dark && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Fluent-dark && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Chicago95 && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Chicago95_Animated_Hourglass_Cursors && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Chicago95 && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Chicago95 && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Chicago95 && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarTreePane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s RedmondXP_Luna && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s DMZ-White && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s RedmondXP && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s RedmondXP_Luna && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarTreePane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Redmond7 && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s DMZ-White && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Redmond7 && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Redmond7 && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s Redmond10 && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s DMZ-White && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s Redmond10 && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s Redmond10 && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarShortcutsPane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
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
        xfconf-query -t string -c xfwm4 -p /general/theme -s LaStrange && \
        xfconf-query -t string -c xsettings -p /Gtk/CursorThemeName -s Adwaita && \
        xfconf-query -t string -c xsettings -p /Net/IconThemeName -s LaStrange && \
        xfconf-query -t string -c xsettings -p /Net/ThemeName -s LaStrange && \
        xfconf-query -t string -c xsettings -p /Net/SoundThemeName -s Smooth && \
        xfconf-query -n -t string -c thunar -p /last-side-pane -s ThunarTreePane && \
        echo -n -e "${white}${bold}Corrigiendo iconos de algunas aplicaciones con hardcode-tray..." && \
        sudo hardcode-tray --apply > /dev/null && \
        echo -e "${white}${bold} Hecho." && \
        xfce4-panel -r && xfdesktop -R && \
        sleep 3 && \
        echo -e "${white}${bold}Tema 'LaStrange' establecido.${reset}" && \
        notify-send -a xfce4-settings-editor -i org.xfce.settings.appearance -t 8000 "Tema 'LaStrange' establecido"
}

function demo() {

    ALDOS ; sleep 20; ALDOSDarker ; sleep 20; Adwaita ; sleep 20; Amber ; sleep 20; AmberCircle ; sleep 20; Arc ; sleep 20; ArcDarker ; sleep 20; Chicago95 ; sleep 20; Dracula ; sleep 20; Fluent ; sleep 20; FluentDark ; sleep 20; Greybird ; sleep 20; LaStrange ; sleep 20; Layan ; sleep 20; Materia ; sleep 20; MateriaDark ; sleep 20; MojaveDark ; sleep 20; MojaveLight ; sleep 20; Nordic ; sleep 20; NordicPolar ; sleep 20; Numix ; sleep 20; NumixCircle ; sleep 20; NumixSquare ; sleep 20; Plano ; sleep 20; PlanoLight ; sleep 20; Qogir ; sleep 20; QogirDark ; sleep 20; QogirLight ; sleep 20; Redmond10 ; sleep 20; Redmond7 ; sleep 20; RedmondXP ; sleep 20; Vimix ; sleep 20; VimixDark ; sleep 20; WhiteSurDark ; sleep 20; WhiteSurLight; sleep 20 ; ALDOS;

}

$1
