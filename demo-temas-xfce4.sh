#!/bin/bash

TIPOGRAFIA='Montserrat Black 48'

rpm -q --quiet aosd_cat simplescreenrecorder xdotool || pkcon -y install aosd_cat simplescreenrecorder xdotool

clear && \
for i in {10..01}
do
    tput cup 1
    echo -n "Iniciando en presentación en ${i} segundos. CTRL+C para interrumpir."
    sleep 1
done && \
echo && \
xdotool key Ctrl+Shift+r && \
sleep 5 && \
for TEMA in \
    Arc \
    Adwaita \
    AdwaitaDark \
    Ant \
    AmberCircle \
    ColloidDark \
    Dracula \
    DraculaCandy \
    FluentDark \
    Graphite \
    Greybird \
    Kimi \
    Layan \
    MojaveDark \
    MojaveLight \
    Nordic \
    Nephrite \
    NephriteLight \
    Otis \
    Qogir \
    QogirDark \
    Snow \
    Vimix \
    VimixDark \
    WhiteSurDark \
    WhiteSurLight  \
    Chicago95 \
    Redmond98 \
    RedmondXP \
    Redmond7 \
    Redmond10 \
    ALDOS \
    ALDOSDarker
do
	tema-xfce4.sh ${TEMA} && \
  echo -e "Tema ${TEMA}" | aosd_cat   -n "${TIPOGRAFIA}" -u 5000 -o 300 -R orange -S black -f 300 -y -540 -x 50 -t 2 -e 5 && \
	sleep 3
	xdotool key Super_L
	sleep 5
	xdotool key Super_L
	sleep 1
    xdotool key Alt+F2+r && \
    sleep 1 && \
    xdotool type "awf-gtk3" && sleep 2 && \
    xdotool key "Return" && \
    sleep 7 && \
    xdotool key Alt+F4
    sleep 2
done

xdotool key Ctrl+Shift+r
