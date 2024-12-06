#!/bin/bash
#set -e
################################################################################
# This is a bash script to automatically create an ALDOS LiveCD
# First released on Dec 1, 2024
#
# Copyright (C) 2024 Joel Barrios Dueñas
# darkshram at gmail dot com
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#
################################################################################

# Convierte la fecha a formato YYYYMMDD
FECHA="$(date +%Y%m%d)"
export FECHA

######################################################################
######################################################################
################                                      ################
################  Variables que se pueden modificar.  ################
################                                      ################
######################################################################
######################################################################

# Procurar sea un nombre conciso y corto
DISTRONAME="ALDOS"
# DISTRONAMELOWERCASE Convierte a minúsculas el valor de DISTRONAME
# Sugiero evitar modificar el valor actual de esta variable.
DISTRONAMELOWERCASE="$(echo ${DISTRONAME} | tr '[:upper:]' '[:lower:]')"
export DISTRONAMELOWERCASE
# Versión del lanzamiento
DISTROVERSION="1.4.19"
PUBLISHER="Joel Barrios"
RELEASENOTESURL="https://www.alcancelibre.org/noticias/disponible-aldos-1-4-19"
# Opciones de localización, mapa de teclado, tipografía para la
# consola, tema para Plymouth y nombre de anfitrión
LIVECDLOCALE="es_MX.UTF-8"
LIVECDKEYMAP="es"
LIVECDSYSFONT="latarcyrheb-sun16"
PLYMOUTHEME="spinfinity"
LIVECDHOSTNAME="aldos-livecd"

# Cadenas para traducir o personalizar
LIVECDWELCOME="Bienvenido a ${LIVECDTITLE}!"
LABELBOOT="Iniciar sistema vivo/Instalar sistema"
LABELBASIC="Iniciar modo seguro (GPU bajos recursos)"
LABELCHECK="Modo verificar e Iniciar"
LABELLOCAL="Iniciar desde unidad local"
COMMENTLIVEUSER="Usuario Sistema Vivo"
INSTALLMSG="Instalar ${DISTRONAME}"

# PROYECTDIR debe ser una ruta absoluta
PROYECTDIR="/home/jbarrios/Proyectos/${DISTRONAME}-LiveCD"
# Archivos LEEME, Licencia, lista de paquetes e imagen a continuación
# deben estar dentro de la ruta definida en PROYECTDIR
READMEFILENAME="LEEME.txt"
LICENSEFILENAME="Licencia.txt"
PACKAGELISTFILENAME="PAQUETES.txt"
# Imagen que se mostrará en pantalla en el gestor de arranque de la
# imagen viva. Se prefiere sea en formato JPG para procurar
# compatibilidad.
SPLASHIMAGEFILENAME="syslinux-vesa-splash.jpg"

# Colores para algunas salidas.
export red="\e[0;91m"
export blue="\e[0;94m"
export green="\e[0;92m"
export purple="\e[1;95m"
export white="\e[0;97m"
#export blackbg="\e[0;40m"
export bold="\e[1m"
export reset="\e[0m"

# Ruta donde se realizará todo el trabajo de crear una imagen de
# disco, se montará como si fuera una partición, se instalará los
# paquetes y finalmente se comprimirá con Squashfs.
# Se recomienda sea un directorio montando un dispositivo tmpfs con
# al menos 12 MB libres.
LIVECDTMPDIR="/tmp/${DISTRONAMELOWERCASE}-livecd"

######################################################################
######################################################################
####                                                              ####
#### Variables que puede, pero que se sugiere se evite modificar. ####
####                                                              ####
######################################################################
######################################################################
ISOLINUXFS="${LIVECDTMPDIR}/${DISTRONAMELOWERCASE}-isolinuxfs"
ROOTFSDIR="${LIVECDTMPDIR}/${DISTRONAMELOWERCASE}-rootfs/livecd"
EXT4FSIMG="${LIVECDTMPDIR}/${DISTRONAMELOWERCASE}-rootfs/${DISTRONAMELOWERCASE}-ext4fs.img"
SQUASHFSIMG="${ISOLINUXFS}/LiveOS/squashfs.img"
LIVECDLABEL="${DISTRONAME}64${FECHA}"
LIVECDTITLE="${DISTRONAME} ${DISTROVERSION} ${FECHA}"
LIVECDFILENAME="${DISTRONAME}-${DISTROVERSION}-${FECHA}"
PACKAGELIST="${PROYECTDIR}/${PACKAGELISTFILENAME}"
LICENSEFILE="${PROYECTDIR}/${LICENSEFILENAME}"
READMEFILE="${PROYECTDIR}/${READMEFILENAME}"
SPLASHIMAGE="${PROYECTDIR}/${SPLASHIMAGEFILENAME}"

######################################################################
######################################################################
#################                                     ################
#################  Modificar sólo hasta acá.          ################
#################                                     ################
######################################################################
######################################################################

######################################################################
######################################################################
################                                      ################
################ No modificar a partir de este punto. ################
################                                      ################
######################################################################
######################################################################

function DESMONTAR() {
umount "${ROOTFSDIR}/dev" && \
umount "${ROOTFSDIR}/proc" && \
umount "${ROOTFSDIR}/sys" && \
umount "${ROOTFSDIR}" && \
rm -fr "${LIVECDTMPDIR}"
echo -e "${red}${bold}Se ha desmontado y eliminado ${LIVECDTMPDIR}...${reset}"
umount "${ROOTFSDIR}"
rm -fr "${LIVECDTMPDIR}"
exit 1
}

export red="\e[0;91m"
export blue="\e[0;94m"
export green="\e[0;92m"
export purple="\e[1;95m"
export white="\e[0;97m"
#export blackbg="\e[0;40m"
export bold="\e[1m"
export reset="\e[0m"

if [ -d "${LIVECDTMPDIR}" ]; then
echo -e "${red}${bold}Directorio existe ${LIVECDTMPDIR}... Tendrá que eliminarlo y volver a ejecutar este programa.${reset}"
     DESMONTAR
fi

clear
echo -e "${green}${bold}$(printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -)${reset}"
echo -e "${white}${bold}Datos para la creación de Imagen Viva de ${DISTRONAME}:${reset}"
echo -e " Título de imagen ISO:            ${blue}${bold}${LIVECDTITLE}${reset}"
echo -e " Archivo imagen ISO:              ${blue}${bold}${LIVECDFILENAME}.iso${reset}"
echo -e " Etiqueta de imagen ISO:          ${blue}${bold}${LIVECDLABEL}${reset}"
echo -e " Autor de imagen ISO:             ${blue}${bold}${PUBLISHER}${reset}"
echo -e "\n${white}${bold}Configuración de sistema operativo en Imagen Viva:${reset}"
echo -e " Localización:                    ${blue}${bold}${LIVECDLOCALE}${reset}"
echo -e " Mapa de teclado:                 ${blue}${bold}${LIVECDKEYMAP}${reset}"
echo -e " Tipografía de la consola:        ${blue}${bold}${LIVECDSYSFONT}${reset}"
echo -e " Tema para Plymouth:              ${blue}${bold}${PLYMOUTHEME}${reset}"
echo -e " Nombre de anfitrión:             ${blue}${bold}${LIVECDHOSTNAME}${reset}"
echo -e "\n${white}${bold}Ruta y archivos del proyecto:${reset}"
echo -e " Directorio temporal:             ${blue}${bold}${LIVECDTMPDIR}${reset}"
echo -e " Directorio del proyecto:         ${blue}${bold}${PROYECTDIR}${reset}"
echo -e " Archivo con lista de paquetes:   ${blue}${bold} → ${PACKAGELISTFILENAME}${reset}"
echo -e " Archivo para licencia:           ${blue}${bold} → ${LICENSEFILENAME}${reset}"
echo -e " Archivo para LÉEME:              ${blue}${bold} → ${READMEFILENAME}${reset}"
echo -e " Archivo para splash.jpg:         ${blue}${bold} → ${SPLASHIMAGEFILENAME}${reset}"
echo -e "${green}${bold}$(printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -)${reset}"
echo -e "${white}${bold}¿Son correctos estos valores? (s/n) [s]${reset}"
read -r ok
echo "${ok}" > /dev/null
if  [[  "${ok}" == "n"  ]]  ||  [[  "${ok}" == "N"  ]]  ; then
    echo -e "${red}${bold} * Proceso cancelado. Por favor, corrija datos.${reset}"
    exit ;
fi
if [ "$(id -u)" != "0" ]; then
    echo -e "${red}${bold} * Este programa sólo puede ser ejecutado como 'root'${reset}\n" 1>&2
    exit 1
fi
clear
echo -e "${green}${bold}Iniciando proceso...${reset}"
######################################################################

# Generar estructura de directorios del LiveCD
echo -e "${green}${bold}Generando estructura de directorios de Imagen Viva...${reset}"
mkdir -p "${ISOLINUXFS}"/{boot/grub/x86_64-efi,efi/boot,isolinux,LiveOS}
# Generar directorio donde se va a instalar el sistema operativo que
# se utilizará posteriormente para el LiveCD
mkdir -p "${ROOTFSDIR}"

# Crear imagen de disco, darle formato y verificar ésta.
# Se desactiva temporalmente la detección de nuevas unidades de
# almacenamiento para impedir que los administradores de archivos u
# otras aplicaciones interfieran con la gestión de la imagen de disco.
# Se monta la imagen de disco y vincula a directorios de dispositivos.
# procesos y funciones del núcleo.
echo -e "${green}${bold}Generando imagen de disco temporal...${reset}"
dd if="/dev/zero" of="${EXT4FSIMG}" bs=4M count=2000 && \
mkfs.ext4 "${EXT4FSIMG}" > /dev/null && \
fsck -fyD "${EXT4FSIMG}" || \
exit 1

echo -e "${green}${bold}Desactivando (temporalmente) montaje automático de unidades de almacenamiento...${reset}"
mkdir -p /lib/udev/rules.d && \
echo 'SUBSYSTEM=="block", ENV{UDISKS_IGNORE}="1"' > /lib/udev/rules.d/90-udisks-inhibit.rules && \
udevadm control --reload && \
udevadm trigger --subsystem-match=block || \
exit 1

echo -e "${green}${bold}Montando sistema de archivos imagen de disco temporal...${reset}"
mount -o loop -t ext4 "${EXT4FSIMG}" "${ROOTFSDIR}" && \
mkdir -p "${ROOTFSDIR}"/{dev,proc,sys} && \
mount -o bind /dev "${ROOTFSDIR}"/dev && \
mount -o bind /proc "${ROOTFSDIR}"/proc && \
mount -o bind /sys "${ROOTFSDIR}"/sys || \
exit 1

# Instalar paquetes mínimos requeridos por los demás
echo -e "${green}${bold}Instalando paquetes esenciales...${reset}"
yum \
    -y \
    --installroot="${ROOTFSDIR}" \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd \
    install \
    libgcc.x86_64 \
    setup.noarch \
    filesystem.x86_64 \
    tzdata.noarch \
    basesystem.noarch \
    cups-filesystem.noarch \
    emacs-filesystem.noarch \
    firewalld-filesystem.noarch \
    foomatic-db-filesystem.noarch \
    mesa-filesystem.x86_64 \
    vim-filesystem.noarch \
    DESMONTAR

# Instalar todos los paquetes que componen la instalación
echo -e "${green}${bold}Instalando paquetería de acuerdo al archivo ${PACKAGELIST} ...${reset}"
cat "${PACKAGELIST}" | xargs \
  yum \
    -y \
    --installroot="${ROOTFSDIR}" \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd \
    install || \
    DESMONTAR

killall cupsd || :

echo -e "${green}${bold}Creando archivo fstab...${reset}"
# El archivo fstab que utilizará el sistema vivo.
cat << EOF > "${ROOTFSDIR}"/etc/fstab
/dev/root  /         ext4    defaults,noatime,nodiratime,commit=30,data=writeback 0 0
EOF

echo -e "${green}${bold}Personalizando el sistema...${reset}"
mkdir -p "${ROOTFSDIR}/boot/efi/System/Library/CoreServices/"
cat << EOF > "${ROOTFSDIR}/boot/efi/System/Library/CoreServices/SystemVersion.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>ProductBuildVersion</key>
        <string>${FECHA}</string>
        <key>ProductName</key>
        <string>Linux</string>
        <key>ProductVersion</key>
        <string>${LABELBOOT}</string>
</dict>
</plist>
EOF

# Personalizar sistema
echo -e "${green}${bold}Configurando sistema de identificación y recursos de autenticación...${reset}"
chroot "${ROOTFSDIR}" /usr/bin/authselect check >/dev/null 2>&1 || :
chroot "${ROOTFSDIR}" /usr/bin/authselect select sssd --force >/dev/null 2>&1 || :
echo -e "${green}${bold}Estableciendo ${PLYMOUTHEME} como tema para Plymouth...${reset}"
chroot "${ROOTFSDIR}" /usr/sbin/plymouth-set-default-theme ${PLYMOUTHEME}
echo -e "${green}${bold}Regenerando initramfs...${reset}"
chroot "${ROOTFSDIR}" /sbin/dracut -f --add-drivers="btrfs binfmt_misc squashfs udf xfs zstd zstd_compress zstd_decompress"
echo -e "${green}${bold}Creando configuración de grub2...${reset}"
chroot "${ROOTFSDIR}" /usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg
chroot "${ROOTFSDIR}" /usr/sbin/grub2-mkconfig -o /boot/efi/EFI/aldos/grub.cfg
echo -e "${green}${bold}Generando machine-id...${reset}"
chroot "${ROOTFSDIR}" /bin/dbus-uuidgen > /var/lib/dbus/machine-id
echo -e "${green}${bold}Eliminando contraseña de 'root'...${reset}"
chroot "${ROOTFSDIR}" /usr/bin/passwd -f -u root 2>&1 || :
# Definir que root puede acceder sin contraseña
chroot "${ROOTFSDIR}" /usr/bin/passwd -d root
# Crear grupos útiles para aplicaciones que pudiera instalar
# posteriormente el usuario
echo -e "${green}${bold}Generando grupos de usuarios adicionales...${reset}"
chroot "${ROOTFSDIR}" /usr/sbin/groupadd -r gamemode 2>&1 || :
chroot "${ROOTFSDIR}" /usr/sbin/groupadd -r seat 2>&1 || :
chroot "${ROOTFSDIR}" /usr/sbin/groupadd -r vboxusers 2>&1 || :
# Asegurar las pertenencias de estos directorios
chroot "${ROOTFSDIR}" /bin/chown polkitd /etc/polkit-1/rules.d > /dev/null 2>&1 ||:
chroot "${ROOTFSDIR}" /bin/chown polkitd /usr/share/polkit-1/rules.d  > /dev/null 2>&1 ||:
echo -e "${green}${bold}Ajustes menores...${reset}"
chroot "${ROOTFSDIR}" /usr/sbin/makewhatis -w > /dev/null 2>&1 ||:
# Crear /etc/resolv.conf
chroot "${ROOTFSDIR}" /bin/touch /etc/resolv.conf
echo -e "${green}${bold}Limpieza de base de datos RPM y YUM...${reset}"
# Limpieza de yum
chroot "${ROOTFSDIR}" /bin/rm -fr /var/lib/yum/{groups,history,repos,rpmdb-indexes,uuid,yumdb}
chroot "${ROOTFSDIR}" /bin/mkdir -p /var/lib/yum/{history,yumdb}
# Limpieza de rpm
chroot "${ROOTFSDIR}" rm -f /var/lib/rpm/__db*
# Algunos de los +2000 paquete crea ésto tras instalarse. Eliminamos
# mientras averiguo exactamente qué lo genera.
chroot "${ROOTFSDIR}" /bin/rm -f /1

# Desactivar SELinux
echo -e "${green}${bold}Desactivando SELinux...${reset}"
sed -i \
    -e "s|SELINUX=.*|SELINUX=disabled|g" \
    "${ROOTFSDIR}/etc/sysconfig/selinux"

# Establecer idioma, mapa de teclado y tipografía para la terminal
echo -e "${green}${bold}Configurando idioma y teclado...${reset}"
sed -i \
    -e "s|LANG=.*|LANG=\"${LIVECDLOCALE}\"|g" \
    -e "s|LC_ALL=.*|LC_ALL=\"${LIVECDLOCALE}\"|g" \
    -e "s|SYSFONT=.*|SYSFONT=\"${LIVECDSYSFONT}\"|g" \
    "${ROOTFSDIR}/etc/locale.conf" \
    "${ROOTFSDIR}/etc/environment"

sed -i \
    -e "LAYOUT=.*|LAYOUT=\"${LIVECDKEYMAP}\"|g" \
    -e "KEYTABLE=.*|LAYOUT=\"${LIVECDKEYMAP}\"|g" \
    -e "KEYMAP=.*|KEYMAP=\"${LIVECDKEYMAP}\"|g" \
    -e "ONT=.*|ONT=\"${LIVECDSYSFONT}\"|g" \
    "${ROOTFSDIR}/etc/vconsole.conf"

sed -i \
    -e "s|value=\"es\"|value=\"${LIVECDKEYMAP}\"|g" \
    -e "s|Usuario Sistema Vivo|${COMMENTLIVEUSER}|g" \
    -e "s|Instalar ALDOS|${INSTALLMSG}|g" \
    "${ROOTFSDIR}/etc/rc.d/init.d/livesys"

sed -i \
    -e "s|rd.locale.LANG=.*|rd.locale.LANG=${LIVECDLOCALE}|g" \
    -e "s|rd.vconsole.keymap=.*|rd.vconsole.keymap=${LIVECDKEYMAP}|g" \
    -e "s|rd.vconsole.font=.*|rd.vconsole.font=${LIVECDSYSFONT}|g" \
    "${ROOTFSDIR}/etc/default/grub"

# Nombre de anfitrión predeterminado
echo -e "${green}${bold}Estableciendo nombre de anfitrión del sistema...${reset}"
sed -i \
    -e "s|HOSTNAME=.*|HOSTNAME=\"${LIVECDHOSTNAME}\"|g" \
    /etc/sysconfig/network && \
echo "${LIVECDHOSTNAME}" > /etc/hostname
echo -e "127.0.0.1    ${LIVECDHOSTNAME}\n::1    ${LIVECDHOSTNAME}" >> /etc/hosts

# Copiar el núcleo del sistema y lo necesario para iniciar el LiveCD.
# Los nombres de los archivos se procuran de máximo 12 caracteres.

# Archivos necesarios para iniciar con BIOS.
echo -e "${green}${bold}Copiando archivos necesarios para el arranque de la imagen viva...${reset}"
cp -a \
    "${ROOTFSDIR}/boot/vmlinuz-*" \
    "${ISOLINUXFS}/isolinux/vmlinuz0"

pushd "${ISOLINUXFS}/isolinux" || exit 1
    sha512hmac vmlinuz0 > .vmlinuz0.hmac
popd || exit 1

cp -a \
    "${ROOTFSDIR}/boot/initramfs-*.img" \
    "${ISOLINUXFS}/isolinux/initrd0.img"

cp -a \
    "${ROOTFSDIR}/usr/share/syslinux/isolinux.bin" \
    "${ISOLINUXFS}/isolinux/isolinux.bin"

cp -a \
    "${ROOTFSDIR}/usr/share/syslinux/vesamenu.c32" \
    "${ISOLINUXFS}/isolinux/vesamenu.c32"

cp -a \
    "${SPLASHIMAGE}" \
    "${ISOLINUXFS}/isolinux/splash.jpg"

# TODO: Archivos requeridos para iniciar con EFI.
cp -a \
    "${ROOTFSDIR}/boot/efi/EFI/aldos/grubx64.efi" \
    "${ISOLINUXFS}/efi/boot/grubx64.efi"

cp -a \
    "${ROOTFSDIR}/boot/efi/EFI/aldos/gcdx64.efi" \
    "${ISOLINUXFS}/efi/boot/gcdx64.efi"

cp -a \
    "${ROOTFSDIR}/boot/efi/EFI/aldos/grubenv" \
    "${ISOLINUXFS}/efi/boot/grubenv"

cp -a \
    "${ROOTFSDIR}/boot/efi/EFI/aldos/fonts/unicode.pf2" \
    "${ISOLINUXFS}/efi/boot/unicode.pf2"

cp -a \
    "${ROOTFSDIR}/boot/efi/mach_kernel" \
    "${ISOLINUXFS}/efi/mach_kernel"

cp -a \
    "${ROOTFSDIR}/boot/grub/splash*gz" \
    "${ISOLINUXFS}/boot/grub/"

cp -a \
    "${ROOTFSDIR}/boot/grub2/fonts/unicode.pf2" \
    "${ISOLINUXFS}/boot/grub/"

cp -a \
    "${ROOTFSDIR}/boot/grub2/themes" \
    "${ISOLINUXFS}/boot/grub/"

mkdir -p "${ISOLINUXFS}/efi/System/Library/CoreServices/"
cp -a \
    "${ROOTFSDIR}/boot/efi/System/Library/CoreServices/SystemVersion.plist" \
    "${ISOLINUXFS}/efi/System/Library/CoreServices/SystemVersion.plist"

cat << EOF > "${ISOLINUXFS}/boot/grub/grub.cfg"
if loadfont \$prefix/unicode.pf2 ; then
  set gfxmode=1024x768x32
  insmod efi_gop
  insmod efi_uga
  insmod video_bochs
  insmod video_cirrus
  insmod gfxterm
  insmod jpeg
  insmod png
  terminal_output gfxterm
fi

insmod gfxmenu
loadfont \$prefix/grub/themes/system/DejaVuSans-10.pf2
loadfont \$prefix/grub/themes/system/DejaVuSans-12.pf2
loadfont \$prefix/grub/themes/system/DejaVuSans-Bold-14.pf2
loadfont \$prefix/grub/fonts/unicode.pf2
insmod png
set theme=\$prefix/grub/themes/system/theme.txt
export theme

menuentry "${LABELBOOT}" {
    set gfxpayload=keep
    
    linux /syslinux/vmlinuz0 root=live:CDLABEL=${LIVECDLABEL} rd.live.image rd.live.dir=/LiveOS rd.live.squashimg=${SQUASHFSIMG} liveimg selinux=0 rootfstype=auto rd.locale.LANG=${LIVECDLOCALE} KEYBOARDTYPE=pc rd.vconsole.keymap=${LIVECDKEYMAP} rootflags=defaults,relatime,commit=60 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM auto noprompt priority=critical mitigations=off amd_pstate.enable=0 intel_pstate=disable loglevel=0 nowatchdog slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on vsyscall=none oops=panic module.sig_enforce=1 lockdown=confidentiality mce=0 loglevel=0 fsck.mode=skip quiet splash
    initrd /syslinux/initrd0.img
}

menuentry "${LABELBASIC}" {
    set gfxpayload=keep
    
    linux /syslinux/vmlinuz0 root=live:CDLABEL=${LIVECDLABEL} rd.live.image rd.live.dir=/LiveOS rd.live.squashimg=${SQUASHFSIMG} liveimg selinux=0 rootfstype=auto rd.locale.LANG=${LIVECDLOCALE} KEYBOARDTYPE=pc rd.vconsole.keymap=${LIVECDKEYMAP} rootflags=defaults,relatime,commit=60 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM auto noprompt priority=critical nomodeset apparmor=0 net.ifnames=0 noapic noapm nodma nomce nolapic nosmp vga=normal mitigations=off amd_pstate.enable=0 intel_pstate=disable loglevel=0 nowatchdog elevator=noop slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on vsyscall=none debugfs=off oops=panic module.sig_enforce=1 lockdown=confidentiality mce=0 loglevel=0 fsck.mode=skip quiet splash 
    initrd /syslinux/initrd0.img
}
EOF

cp -a \
    "${ISOLINUXFS}/boot/grub/grub.cfg" \
    "${ISOLINUXFS}/boot/grub/x86_64-efi/grub.cfg"

echo -e "${green}${bold}Creando configuración de gestor de arranque SysLinux...${reset}"
# Crear el menú de SysLinux (gestor de arranque del LiveCD)
cat << EOF > "${ISOLINUXFS}/isolinux/isolinux.cfg"
default vesamenu.c32
timeout 500

menu background splash.jpg
menu title ${LIVECDWELCOME}
menu color border 0 #ffffffff #00000000
menu color sel 7 #ffffffff #ff000000
menu color title 0 #ffffffff #00000000
menu color tabmsg 0 #ffffffff #00000000
menu color unsel 0 #ffffffff #00000000
menu color hotsel 0 #ff000000 #ffffffff
menu color hotkey 7 #ffffffff #ff000000
menu color timeout_msg 0 #ffffffff #00000000
menu color timeout 0 #ffffffff #00000000
menu color cmdline 0 #ffffffff #00000000
menu hidden
menu hiddenrow 5
label linux0
  menu label ${LIVECDTITLE} - ${LABELBOOT}
  kernel vmlinuz0
  append initrd=initrd0.img root=live:CDLABEL=${LIVECDLABEL} rootfstype=auto ro liveimg rd.locale.LANG=${LIVECDLOCALE} KEYBOARDTYPE=pc SYSFONT=${LIVECDSYSFONT} rd.vconsole.keymap=${LIVECDKEYMAP} rootflags=defaults,relatime,commit=60 selinux=0 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM quiet splash
menu default
label linux0
  menu label ${LIVECDTITLE} - ${LABELBASIC}
  kernel vmlinuz0
  append initrd=initrd0.img root=live:CDLABEL=${LIVECDLABEL} rootfstype=auto ro liveimg rd.locale.LANG=${LIVECDLOCALE} KEYBOARDTYPE=pc SYSFONT=${LIVECDSYSFONT} rd.vconsole.keymap=${LIVECDKEYMAP} rootflags=defaults,relatime,commit=60 selinux=0 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM rd_NO_PLYMOUTH=1 xdriver=vesa nomodeset quiet
label check0
  menu label ${LIVECDTITLE} - ${LABELCHECK}
  kernel vmlinuz0
  append initrd=initrd0.img root=live:CDLABEL=${LIVECDLABEL} rootfstype=auto ro liveimg rd.locale.LANG=${LIVECDLOCALE} KEYBOARDTYPE=pc SYSFONT=${LIVECDSYSFONT} rd.vconsole.keymap=${LIVECDKEYMAP} rootflags=defaults,relatime,commit=60 selinux=0 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM check quiet splash
label local
  menu label ${LABELLOCAL}
  localboot 0xffff
EOF

echo -e "${green}${bold}Copiando archivos de licencia y léeme en imagen viva...${reset}"
# Copiar archivo de licencia
cp -a \
    "${LICENSEFILE}" \
    "${ISOLINUXFS}/${LICENSEFILENAME}"

# Copiar archivo LEEME.txt
cp -a \
    "${READMEFILE}" \
    "${ISOLINUXFS}/${READMEFILENAME}"

echo -e "${green}${bold}Creando archivos de identidad del Sistema Operativo en imagen viva...${reset}"
touch "${ISOLINUXFS}/${DISTRONAMELOWERCASE}" && \
mkdir "${ISOLINUXFS}/.disk" && \
touch "${ISOLINUXFS}/.disk/base_installable" && \
echo "full_cd/single" > "${ISOLINUXFS}/.disk/cd_type" && \
echo "${LIVECDTITLE}" > "${ISOLINUXFS}/.disk/info" && \
echo "${RELEASENOTESURL}" > "${ISOLINUXFS}/.disk/release_notes_url" || \
exit 1

echo -e "${green}${bold}Generando archivo de sumas MD5...${reset}"
pushd "${ISOLINUXFS}" || exit 1
find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt
popd || exit 1

# Forzar la escrita a sistema de archivos de todas las consignaciones
# pendientes en el búfer de memoria.
sync

# Desmontar sistemas de archivos
echo -e "${green}${bold}Desmontando sistemas de archivos virtuales de imagen de disco...${reset}"
killall cupsd || :
umount "${ROOTFSDIR}/sys" && \
umount "${ROOTFSDIR}/proc" && \
umount "${ROOTFSDIR}/dev" && \
umount "${ROOTFSDIR}" || \
exit 1

if [ -e "${EXT4FSIMG}" ]; then
# Verificar y poner en cero los bloques vacíos
echo -e "${green}${bold}Verificando en 2 pasos sistema de archivos de imagen de disco...${reset}"
fsck -fyD "${EXT4FSIMG}" > /dev/null && \
zerofree "${EXT4FSIMG}" > /dev/null && \
fsck -fyD "${EXT4FSIMG}" > /dev/null || \
exit 1
fi

echo -e "${green}${bold}Montando nuevamente sistema de archivos imagen de disco temporal...${reset}"
mount -o loop -t ext4 "${EXT4FSIMG}" "${ROOTFSDIR}" || \
exit 1

if [ -e "${ROOTFSDIR}" ]; then
# Comprimir imagen de disco con squashfs y algoritmo xz.
echo -e "${green}${bold}Creando imagen de disco comprimida con Squashfs...${reset}"
mksquashfs \
    "${ROOTFSDIR}" \
    "${SQUASHFSIMG}" \
    -quiet -comp xz -b 4096 > /dev/null
else
exit 1
fi

if [ -e "${SQUASHFSIMG}" ]; then
# Calcular tamaño de la imagen de disco comprimida
MAXSIZE="2147483648"
FILESIZE="$(stat -c%s "${SQUASHFSIMG}")"

echo -e "${green}${bold}Concluido. Tamaño de ${SQUASHFSIMG} es ${FILESIZE} bytes...${reset}"

echo -e "${green}${bold}Desmontando sistemas de archivos de imagen de disco...${reset}"
umount "${ROOTFSDIR}" || \
exit 1
# Intentar liberar todos los dispositivos /dev/loopX
losetup --detach-all || :

# Eliminar regla temporal que impide montaje automático de unidades
# de almacenamiento en el anfitrión
echo -e "${green}${bold}Reactivando montaje automático de unidades de almacenamiento...${reset}"
rm -f /lib/udev/rules.d/90-udisks-inhibit.rules
udevadm control --reload
udevadm trigger --subsystem-match=block

echo -e "${green}${bold}Creando imagen ISO final...${reset}"

# xorriso is an actively mantained tool but...
# genisoimage is the first choice if files are bigger than 2GB

if (( FILESIZE > MAXSIZE )); then
echo -e "${green}${bold}Creando imagen ISO final con genisoimage...${reset}"
genisoimage \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-boot isolinux/isolinux.bin \
    -eltorito-catalog isolinux/boot.cat \
    -eltorito-alt-boot \
    -joliet \
    -joliet-long \
    -rock \
    -rational-rock \
    -full-iso9660-filenames \
    -isohybrid-mbr \
    -allow-limited-size \
    -udf \
    -appid "${DISTRONAME}" \
    -sysid LINUX \
    -volid "${LIVECDLABEL}" \
    -copyright "${LICENSEFILENAME}" \
    -publisher "${PUBLISHER}" \
    -checksum-list "md5sum.txt" \
    -o "${LIVECDFILENAME}.iso" \
    "${ISOLINUXFS}" || \
    exit 1
    echo -e "${green}${bold}Eliminando ${LIVECDTMPDIR}...${reset}"
    rm -fr "${LIVECDTMPDIR}" || \
    exit 1
else
echo -e "${green}${bold}Creando imagen ISO final con xorrisofs...${reset}"
xorrisofs \
    -no-emul-boot \
    -boot-load-size 4 \
    -boot-info-table \
    -eltorito-boot isolinux/isolinux.bin \
    -eltorito-catalog isolinux/boot.cat \
    -eltorito-alt-boot \
    -joliet \
    -joliet-long \
    -rock \
    -rational-rock \
    -full-iso9660-filenames \
    -isohybrid-mbr \
    -appid "${DISTRONAME}" \
    -sysid LINUX \
    -volid "${LIVECDLABEL}" \
    -copyright "${LICENSEFILENAME}" \
    -publisher "${PUBLISHER}" \
    -checksum-list "md5sum.txt" \
    -o "${PROYECTDIR}/${LIVECDFILENAME}.iso" \
    "${ISOLINUXFS}" || \
    exit 1
    echo -e "${green}${bold}Eliminando ${LIVECDTMPDIR}...${reset}"
    rm -fr "${LIVECDTMPDIR}" || \
    exit 1
fi

if [ -e "${LIVECDFILENAME}.iso" ]; then
    echo -e "${green}${bold}Concluyendo proceso...${reset}"
    pushd ${PROYECTDIR} || exit 1
    md5sum "${LIVECDFILENAME}" > "${LIVECDFILENAME}.md5sum" && \
    sha256sum "${LIVECDFILENAME}" > "${LIVECDFILENAME}.sha256sum" && \
    sha512sum "${LIVECDFILENAME}" > "${LIVECDFILENAME}.sha512sum" || \
    exit 1
    clear
    echo -e "${green}${bold}$(printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -)${reset}"
    echo -e "${green}${bold}Proceso concluido.${reset}\n"
    echo -e "${white}${bold}Archivos creados:${reset}"
    ISOFILENAME="${LIVECDFILENAME}.iso"
    ISOSIZE="$(stat -c%s "${ISOFILENAME}")"
    export ISOSIZE
    echo -e "    1. ${blue}${bold}${PROYECTDIR}/${purple}${LIVECDFILENAME}.iso${reset}${blue}${bold} (${ISOSIZE} bytes)${reset}"
    echo -e "    2. ${blue}${bold}${PROYECTDIR}/${purple}${LIVECDFILENAME}.md5dum${reset}"
    echo -e "    3. ${blue}${bold}${PROYECTDIR}/${purple}${LIVECDFILENAME}.256sum${reset}"
    echo -e "    4. ${blue}${bold}${PROYECTDIR}/${purple}${LIVECDFILENAME}.512sum${reset}"
    echo -e "${green}${bold}$(printf '%*s\n' "${COLUMNS:-$(tput cols)}" '' | tr ' ' -)${reset}"
    popd || exit 1
fi
else
    echo -e "${red}${bold}Algo salió mal...${reset}"
fi
