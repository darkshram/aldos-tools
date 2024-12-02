#!/bin/bash
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

PROYECTDIR="/home/jbarrios/Proyectos/ALDOS-LiveCD"
PUBLISHER="Joel Barrios"
RELEASENOTESURL="https://www.alcancelibre.org/noticias/disponible-aldos-1-4-19"
LIVECDTMPDIR="/tmp/aldos-livecd"
ISOLINUXFS="${LIVECDTMPDIR}/aldos-isolinuxfs"
ROOTFSDIR="${LIVECDTMPDIR}/aldos-rootfs/livecd"
EXT4FSIMG="${LIVECDTMPDIR}/aldos-rootfs/aldos-ext4fs.img"
SQUASHFSIMG="${ISOLINUXFS}/LiveOS/squashfs.img"
FECHA="$(date +%Y%m%d)"
LIVECDHOSTNAME="aldos-livecd.alcancelibre.org"
DISTRONAME="ALDOS"
LIVECDLABEL="ALDOS64${FECHA}"
LIVECDWELCOME="Bienvenido a ${LIVECDTITLE}!"
LIVECDLOCALE="es_MX.UTF-8"
LIVECDKEYMAP="es"
LIVECDSYSFONT="latarcyrheb-sun16"
LIVECDTITLE="ALDOS 1.4.19 ${FECHA}"
LIVECDFILENAME="ALDOS-1.4.19-${FECHA}"
LABELBOOT="Iniciar sistema vivo/Instalar sistema"
LABELBASIC="Iniciar modo seguro (GPU bajos recursos)"
LABELCHECK="Modo verificar e Iniciar"
LABELLOCAL="Iniciar desde unidad local"
COMMENTLIVEUSER="Usuario Sistema Vivo"
INSTALLMSG="Instalar ALDOS"
READMEFILENAME="LEEME.txt"
LICENSEFILENAME="Licencia.txt"
PACKAGELIST="${PROYECTDIR}/ALDOS-package-list.txt"
LICENSEFILE="${PROYECTDIR}/${LICENSEFILENAME}"
READMEFILE="${PROYECTDIR}/${READMEFILENAME}"
# Imagen que se mostrará en pantalla en el gestor de arranque del
# disco vivo. Se prefiere sea en formato JPG para procurar
# compatibilidad.
SPLASHIMAGE="${PROYECTDIR}/syslinux-vesa-splash.jpg"

######################################################################
######################################################################
################ No modificar a partir de este punto. ################
######################################################################
export red="\e[0;91m"
export blue="\e[0;94m"
export green="\e[0;92m"
export purple="\e[1;95m"
export white="\e[0;97m"
export bold="\e[1m"
export reset="\e[0m"
clear
echo -e "##########################################################################"
echo -e "${white}${bold}Datos para la creación de imagen viva:${reset}"
echo -e " Título del LiveCD:               ${blue}${bold}${LIVECDTITLE}${reset}"
echo -e " Archivo imagen ISO:              ${blue}${bold}${PROYECTDIR}/${LIVECDFILENAME}.iso${reset}"
echo -e " Etiqueta de imagen ISO:          ${blue}${bold}${LIVECDLABEL}${reset}"
echo -e " Idioma:                          ${blue}${bold}${LIVECDLOCALE}${reset}"
echo -e " Mapa de teclado:                 ${blue}${bold}${LIVECDKEYMAP}${reset}"
echo -e " Tipografía de la consola:        ${blue}${bold}${LIVECDSYSFONT}${reset}"
echo -e " Autor:                           ${blue}${bold}${PUBLISHER}${reset}"
echo -e " Directorio del proyecto:         ${blue}${bold}${PROYECTDIR}${reset}"
echo -e " Directorio temporal:             ${blue}${bold}${LIVECDTMPDIR}${reset}"
echo -e " Archivo con lista de paquetes:   ${blue}${bold}${PACKAGELIST}${reset}"
echo -e " Archivo de licencia.txt:         ${blue}${bold}${LICENSEFILE}${reset}"
echo -e " Archivo de LEEME.txt:            ${blue}${bold}${READMEFILE}${reset}"
echo -e " Archivo de splash.jpg:           ${blue}${bold}${SPLASHIMAGE}${reset}"
echo -e " Nombre de anfitrión:             ${blue}${bold}${LIVECDHOSTNAME}${reset}"
echo -e "##########################################################################"
echo -e "${white}${bold}¿Son correctos estos valores? (S/N) [s]${reset}"
read -r ok
echo "${ok}"
if  [[  "${ok}" == "n"  ]]  ||  [[  "${ok}" == "N"  ]]  ; then
    echo -e "${red}${bold}Proceso cancelado. Por favor, corrija datos.${reset}"
    exit ;
fi
if [ "$(id -u)" != "0" ]; then
    echo -e "${red}${bold}Este programa sólo puede ser ejecutado como 'root'${reset}" 1>&2
    exit 1
fi
clear
echo -e "${green}${bold}Iniciando proceso...${reset}"
######################################################################

# Generar estructura de directorios del LiveCD
mkdir -p ${ISOLINUXFS}/{boot/grub/x86_64-efi,efi/boot,isolinux,LiveOS}
# Generar directorio donde se va a instalar el sistema operativo que
# se utilizará posteriormente para el LiveCD
mkdir -p ${ROOTFSDIR}

# Crear imagen de disco, darle formato y verificar ésta.
# Se desactiva temporalmente la detección de nuevas unidades de
# almacenamiento para impedir que los administradores de archivos u
# otras aplicaciones interfieran con la gestión de la imagen de disco.
# Se monta la imagen de disco y vincula a directorios de dispositivos.
# procesos y funciones del núcleo.
dd if="/dev/zero" of="${ISOLINUXFS}/aldos-ext4fs.img" bs=4M count=2000 && \
mkfs.ext4 "${ISOLINUXFS}/aldos-ext4fs.img" && \
fsck -fyD "${ISOLINUXFS}/aldos-ext4fs.img" && \
mkdir -p /lib/udev/rules.d && \
echo 'SUBSYSTEM=="block", ENV{UDISKS_IGNORE}="1"' > /lib/udev/rules.d/90-udisks-inhibit.rules && \
udevadm control --reload && \
udevadm trigger --subsystem-match=block && \
mount -o loop -t ext4 "${EXT4FSIMG}" "${ROOTFSDIR}" && \
mkdir -p "${ROOTFSDIR}"/{dev,proc,sys} && \
mount -o bind /dev "${ROOTFSDIR}"/dev && \
mount -o bind /proc "${ROOTFSDIR}"/proc && \
mount -o bind /sys "${ROOTFSDIR}"/sys

# Instalar paquetes mínimos requeridos por los demás
yum -q -y \
    --installroot="${ROOTFS}" \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd \
    install \
    libgcc.x86_64 \
    setup.noarch \
    filesystem.x86_64 \
    tzdata.noarch \
    basesystem.noarch

# Herramientas que se necesitan para la instalación de paquetes que
# incluyen componentes que se asigna a un usuario o grupo.
yum -q -y \
    --installroot="${ROOTFS}" \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd \
    install \
    glibc-common.x84_64 \
    shadow-utils.x86_64 \
    passwd.noarch > /dev/null

# Herramientas que se necesitan para la instalación de paquetes que
# incluyen servicios.
yum -y \
    --installroot="${ROOTFS}" \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd \
    install \
    chkconfig.x84_64 \
    initscripts-sysvinit.x86_64 \
    sysvinit.x86_64 \
    sysvinit-default.noarch > /dev/null

# Instalar todos los paquetes que componen la instalación
yum -y \
    --installroot="${ROOTFS}" \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd \
    install < "${PACKAGELIST}" > /dev/null

# Instalar Calamares y herramienta para gestionar particiones y
# Volúmenes lógicos. Estos paquetes serán desinstalados después de
# instalar el sistema vivo en el equipo.
yum -y \
    --installroot="${ROOTFS}" \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd \
    install \
    calamares.x86_64 \
    calamares-sysvinit.noarch \
    kde-partitionmanager.x86_64 > /dev/null

# El archivo fstab que utilizará el sistema vivo.
cat << EOF > "${ROOTFS}"/etc/fstab
/dev/root  /         ext4    defaults,noatime,nodiratime,commit=30,data=writeback 0 0
EOF

mkdir -p "${ROOTFS}/boot/efi/System/Library/CoreServices/"
cat << EOF > "${ROOTFS}/boot/efi/System/Library/CoreServices/SystemVersion.plist"
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
chroot "${ROOTFS}" /usr/bin/authselect check >/dev/null 2>&1 || :
chroot "${ROOTFS}" /usr/bin/authselect select sssd --force
chroot "${ROOTFS}" /sbin/dracut -f --add-drivers="btrfs binfmt_misc squashfs xfs zstd zstd_compress zstd_decompress"
chroot "${ROOTFS}" /usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg
chroot "${ROOTFS}" /usr/sbin/grub2-mkconfig -o /boot/efi/EFI/aldos/grub.cfg
chroot "${ROOTFS}" /bin/dbus-uuidgen > /var/lib/dbus/machine-id
# Activar la cuenta de root
chroot "${ROOTFS}" /usr/bin/passwd -f -u root 2>&1 || :
# Definir que root puede acceder sin contraseña
chroot "${ROOTFS}" /usr/bin/passwd -d root
# Crear grupos útiles para aplicaciones que pudiera instalar
# posteriormente el usuario
chroot "${ROOTFS}" /usr/sbin/groupadd -r gamemode 2>&1 || :
chroot "${ROOTFS}" /usr/sbin/groupadd -r seat 2>&1 || :
chroot "${ROOTFS}" /usr/sbin/groupadd -r vboxusers 2>&1 || :
# Asegurar las pertenencias de estos directorios
chroot "${ROOTFS}" /bin/chown polkitd /etc/polkit-1/rules.d > /dev/null 2>&1 ||:
chroot "${ROOTFS}" /bin/chown polkitd /usr/share/polkit-1/rules.d  > /dev/null 2>&1 ||:
# Generar la base de datos de whatis
chroot "${ROOTFS}" /usr/sbin/makewhatis -w
# Crear /etc/resolv.conf
chroot "${ROOTFS}" /bin/touch /etc/resolv.conf
# Limpieza de yum
chroot "${ROOTFS}" /bin/rm -fr /var/lib/yum/{groups,history,repos,rpmdb-indexes,uuid,yumdb}
chroot "${ROOTFS}" /bin/mkdir -p /var/lib/yum/{history,yumdb}
# Limpieza de rpm
chroot "${ROOTFS}" rm -f /var/lib/rpm/__db*
# Algunos de los +2000 paquete crea ésto tras instalarse. Eliminamos
# mientras averiguo exactamente qué lo genera.
chroot "${ROOTFS}" /bin/rm -f /1

# Desactivar SELinux
sed -i \
    -e "s|SELINUX=.*|SELINUX=disabled|g" \
    "${ROOTFS}/etc/sysconfig/selinux"

# Establecer idioma, mapa de teclado y tipografía para la terminal
sed -i \
    -e "s|LANG=.*|LANG=\"${LIVECDLOCALE}\"|g" \
    -e "s|LC_ALL=.*|LC_ALL=\"${LIVECDLOCALE}\"|g" \
    -e "s|SYSFONT=.*|SYSFONT=\"${LIVECDSYSFONT}\"|g" \
    "${ROOTFS}/etc/locale.conf" \
    "${ROOTFS}/etc/environment"

sed -i \
    -e "LAYOUT=.*|LAYOUT=\"${LIVECDKEYMAP}\"|g" \
    -e "KEYTABLE=.*|LAYOUT=\"${LIVECDKEYMAP}\"|g" \
    -e "KEYMAP=.*|KEYMAP=\"${LIVECDKEYMAP}\"|g" \
    -e "ONT=.*|ONT=\"${LIVECDSYSFONT}\"|g" \
    "${ROOTFS}/etc/vconsole.conf"

sed -i \
    -e "s|value=\"es\"|value=\"${LIVECDKEYMAP}\"|g" \
    -e "s|Usuario Sistema Vivo|${COMMENTLIVEUSER}|g" \
    -e "s|Instalar ALDOS|${INSTALLMSG}|g" \
    "${ROOTFS}/etc/rc.d/init.d/livesys"

sed -i \
    -e "s|rd.locale.LANG=.*|rd.locale.LANG=${LIVECDLOCALE}|g" \
    -e "s|rd.vconsole.keymap=.*|rd.vconsole.keymap=${LIVECDKEYMAP}|g" \
    -e "s|rd.vconsole.font=.*|rd.vconsole.font=${LIVECDSYSFONT}|g" \
    "${ROOTFS}/etc/default/grub"

# Nombre de anfitrión predeterminado
sed -i \
    -e "s|HOSTNAME=.*|HOSTNAME=\"${LIVECDHOSTNAME}\"|g" \
    /etc/sysconfig/network && \
echo "${LIVECDHOSTNAME}" > /etc/hostname
echo -e "127.0.0.1    ${LIVECDHOSTNAME}\n::1    ${LIVECDHOSTNAME}" >> /etc/hosts

# Copiar el núcleo del sistema y lo necesario para iniciar el LiveCD.
# Los nombres de los archivos se procuran de máximo 12 caracteres.

# Archivos necesarios para iniciar con BIOS.
cp -a \
    "${ROOTFS}/boot/vmlinuz-*" \
    "${ISOLINUXFS}/syslinux/vmlinuz0"

pushd ${ISOLINUXFS}/syslinux || exit 1
    sha512hmac vmlinuz0 > .vmlinuz0.hmac
popd || exit 1

cp -a \
    "${ROOTFS}/boot/initramfs-*.img" \
    "${ISOLINUXFS}/syslinux/initrd0.img"

cp -a \
    "${ROOTFS}/usr/share/syslinux/isolinux.bin" \
    "${ISOLINUXFS}/isolinux/isolinux.bin"

cp -a \
    "${ROOTFS}/usr/share/syslinux/vesamenu.c32" \
    "${ISOLINUXFS}/isolinux/vesamenu.c32"

cp -a \
    "${SPLASHIMAGE}" \
    "${ISOLINUXFS}/isolinux/splash.jpg"

# TODO: Archivos requeridos para iniciar con EFI.
cp -a \
    "${ROOTFS}/boot/efi/EFI/aldos/grubx64.efi" \
    "${ISOLINUXFS}/efi/boot/grubx64.efi"

cp -a \
    "${ROOTFS}/boot/efi/EFI/aldos/gcdx64.efi" \
    "${ISOLINUXFS}/efi/boot/gcdx64.efi"

cp -a \
    "${ROOTFS}/boot/efi/EFI/aldos/grubenv" \
    "${ISOLINUXFS}/efi/boot/grubenv"

cp -a \
    "${ROOTFS}/boot/efi/EFI/aldos/fonts/unicode.pf2" \
    "${ISOLINUXFS}/efi/boot/unicode.pf2"

cp -a \
    "${ROOTFS}/boot/efi/mach_kernel" \
    "${ISOLINUXFS}/efi/mach_kernel"

cp -a \
    "${ROOTFS}/boot/grub/splash*gz" \
    "${ISOLINUXFS}/boot/grub/"

cp -a \
    "${ROOTFS}/boot/grub2/fonts/unicode.pf2" \
    "${ISOLINUXFS}/boot/grub/"

cp -a \
    "${ROOTFS}/boot/grub2/themes" \
    "${ISOLINUXFS}/boot/grub/"

mkdir -p "${ISOLINUXFS}/efi/System/Library/CoreServices/"
cp -a \
    "${ROOTFS}/boot/efi/System/Library/CoreServices/SystemVersion.plist" \
    "${ISOLINUXFS}/efi/System/Library/CoreServices/SystemVersion.plist"

cat << EOF > ${ISOLINUXFS}/boot/grub/grub.cfg
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
    
    linux /syslinux/vmlinuz0 root=live:CDLABEL=${LIVECDLABEL} rd.live.image rd.live.dir=/LiveOS rd.live.squashimg=${SQUASHFSIMG} selinux=0 rootfstype=auto rd.locale.LANG=${LIVECDLOCALE} KEYBOARDTYPE=pc rd.vconsole.keymap=${LIVECDKEYMAP} rootflags=defaults,relatime,commit=60 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM auto noprompt priority=critical mitigations=off amd_pstate.enable=0 intel_pstate=disable loglevel=0 nowatchdog slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on vsyscall=none oops=panic module.sig_enforce=1 lockdown=confidentiality mce=0 loglevel=0 fsck.mode=skip quiet splash
    initrd /syslinux/initrd0.img
}

menuentry "${LABELBASIC}" {
    set gfxpayload=keep
    
    linux /syslinux/vmlinuz0 root=live:CDLABEL=${LIVECDLABEL} rd.live.image rd.live.dir=/LiveOS rd.live.squashimg=${SQUASHFSIMG} selinux=0 rootfstype=auto rd.locale.LANG=${LIVECDLOCALE} KEYBOARDTYPE=pc rd.vconsole.keymap=${LIVECDKEYMAP} rootflags=defaults,relatime,commit=60 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM auto noprompt priority=critical nomodeset apparmor=0 net.ifnames=0 noapic noapm nodma nomce nolapic nosmp vga=normal mitigations=off amd_pstate.enable=0 intel_pstate=disable loglevel=0 nowatchdog elevator=noop slab_nomerge init_on_alloc=1 init_on_free=1 page_alloc.shuffle=1 pti=on vsyscall=none debugfs=off oops=panic module.sig_enforce=1 lockdown=confidentiality mce=0 loglevel=0 fsck.mode=skip quiet splash 
    initrd /syslinux/initrd0.img
}
EOF

cp -a \
    "${ISOLINUXFS}/boot/grub/grub.cfg" \
    "${ISOLINUXFS}/boot/grub/x86_64-efi/grub.cfg"

# Copiar archivo de licencia
cp -a \
    "${LICENSEFILE}" \
    "${ISOLINUXFS}/${LICENSEFILENAME}"

# Copiar archivo LEEME.txt
cp -a \
    "${READMEFILE}" \
    "${ISOLINUXFS}/${READMEFILENAME}"

# Crear el menú de SysLinux (gestor de arranque del LiveCD)
cat << EOF > "${ISOLINUXFS}"/isolinux/isolinux.cfg
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

touch "${ISOLINUXFS}/aldos"
mkdir "${ISOLINUXFS}/.disk"
touch "${ISOLINUXFS}/.disk/base_installable"
echo "full_cd/single" > "${ISOLINUXFS}/.disk/cd_type"
echo "${LIVECDTITLE}" > "${ISOLINUXFS}/.disk/info"
echo "${RELEASENOTESURL}" > "${ISOLINUXFS}/.disk/release_notes_url"

pushd "${ISOLINUXFS}" || exit 1
find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt
popd || exit 1

# Forzar la escrita a sistema de archivos de todas las consignaciones
# pendientes en el búfer de memoria.
sync

# Desmontar sistemas de archivos
umount "${ROOTFSDIR}/sys"
umount "${ROOTFSDIR}/proc"
umount "${ROOTFSDIR}/dev"
umount "${ROOTFSDIR}"
# Intentar liberar todos los dispositivos /dev/loopX
losetup --detach-all

# Eliminar regla temporal que impide montaje automático de unidades
# de almacenamiento en el anfitrión
rm -f /lib/udev/rules.d/90-udisks-inhibit.rules
udevadm control --reload
udevadm trigger --subsystem-match=block

if [ -e "${EXT4FSIMG}" ]; then
# Verificar y poner en cero los bloques vacíos
fsck -fyD "${EXT4FSIMG}"
zerofree -v "${EXT4FSIMG}"
fsck -fyD "${EXT4FSIMG}"
fi

if [ -e "${ROOTFS}" ]; then
# Comprimir imagen de disco con squashfs y algoritmo xz.
mksquashfs \
    "${ROOTFS}" \
    "${SQUASHFSIMG}" \
    -comp xz \
    -b 4M
else
exit 1
fi

if [ -e "${SQUASHFSIMG}" ]; then
# Calcular tamaño de la imagen de disco comprimida
MAXSIZE="2147483648"
FILESIZE="$(stat -c%s ${SQUASHFSIMG})"

# xorriso is an actively mantained tool but...
# genisoimage is the first choice if files are bigger than 2GB

if (( FILESIZE > MAXSIZE )); then
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
    "${ISOLINUXFS}" && \
    rm -fr "${LIVECDTMPDIR}"
else
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
    "${ISOLINUXFS}" && \
    rm -fr "${LIVECDTMPDIR}"
fi

if [ -e "${LIVECDFILENAME}.iso" ]; then
    pushd ${PROYECTDIR} || exit 1
    md5sum "${LIVECDFILENAME}" > "${LIVECDFILENAME}.md5sum" || exit 1
    sha256sum "${LIVECDFILENAME}" > "${LIVECDFILENAME}.sha256sum" || exit 1
    sha512sum "${LIVECDFILENAME}" > "${LIVECDFILENAME}.sha512sum" || exit 1
    clear
    echo -e "${white}${bold}Proceso concluido.${reset}\n"
    echo -e "${white}${bold}Archivos creados:${reset}"
    echo -e "    - ${blue}${bold}${PROYECTDIR}/${purple}${LIVECDFILENAME}.iso${reset}"
    echo -e "    - ${blue}${bold}${PROYECTDIR}/${purple}${LIVECDFILENAME}.md5dum${reset}"
    echo -e "    - ${blue}${bold}${PROYECTDIR}/${purple}${LIVECDFILENAME}.256sum${reset}"
    echo -e "    - ${blue}${bold}${PROYECTDIR}/${purple}${LIVECDFILENAME}.512sum${reset}"
    popd || exit 1
fi

fi
