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
ISOLINUXFS="/tmp/aldos-livecd"
ROOTFSDIR="/tmp/aldos-rootfs/mnt/livecd"
EXT4FSIMG="/tmp/aldos-rootfs/aldos-ext4fs.img"
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
LIVECDFILE="$(pwd)/ALDOS-1.4.19-${FECHA}.iso"
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
yum -y \
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
yum -y \
    --installroot="${ROOTFS}" \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd \
    install \
    glibc-common.x84_64 \
    shadow-utils.x86_64 \
    passwd.noarch

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
    sysvinit-default.noarch

# Instalar todos los paquetes que componen la instalación
yum -y \
    --installroot="${ROOTFS}" \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd \
    install < "${PACKAGELIST}"

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
    kde-partitionmanager.x86_64

# El archivo fstab que utilizará el sistema vivo.
cat << EOF > "${ROOTFS}"/etc/fstab
/dev/root  /         ext4    defaults,noatime,nodiratime,commit=30,data=writeback 0 0
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
cp -a \
    "${ROOTFS}/vmlinuz-*" \
    "${ISOLINUXFS}/syslinux/vmlinuz0"

cp -a \
    "${ROOTFS}/boot/initrd-plymouth.img" \
    "${ISOLINUXFS}/syslinux/initrd0.img"

cp -a \
    "${ROOTFS}/boot/efi/EFI/aldos/grubx64.efi" \
    "${ISOLINUXFS}/efi/boot/grubx64.efi"

cp -a \
    "${ROOTFS}/usr/share/syslinux/isolinux.bin" \
    "${ISOLINUXFS}/isolinux/isolinux.bin"

cp -a \
    "${ROOTFS}/usr/share/syslinux/vesamenu.c32" \
    "${ISOLINUXFS}/isolinux/vesamenu.c32"

cp -a \
    "${SPLASHIMAGE}" \
    "${ISOLINUXFS}/isolinux/splash.jpg"

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
  menu label ${LABELBOOT}
  kernel vmlinuz0
  append initrd=initrd0.img root=live:CDLABEL=${LIVECDLABEL} rootfstype=auto ro liveimg rd.locale.LANG=${LIVECDLOCALE} KEYBOARDTYPE=pc SYSFONT=${LIVECDSYSFONT} rd.vconsole.keymap=${LIVECDKEYMAP} rootflags=defaults,relatime,commit=60 selinux=0 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM quiet splash
menu default
label linux0
  menu label ${LABELBASIC}
  kernel vmlinuz0
  append initrd=initrd0.img root=live:CDLABEL=${LIVECDLABEL} rootfstype=auto ro liveimg rd.locale.LANG=${LIVECDLOCALE} KEYBOARDTYPE=pc SYSFONT=${LIVECDSYSFONT} rd.vconsole.keymap=${LIVECDKEYMAP} rootflags=defaults,relatime,commit=60 selinux=0 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM rd_NO_PLYMOUTH=1 xdriver=vesa nomodeset quiet
label check0
  menu label ${LABELCHECK}
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

find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt

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
    -o "${LIVECDFILE}.iso" \
    "${ISOLINUXFS}"
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
    -o "${PROYECTDIR}/${LIVECDFILE}.iso" \
    "${ISOLINUXFS}"
fi

if [ -e "${LIVECDFILE}.iso" ]; then
    pushd "${PROYECTDIR}" || exit 1
    md5sum "${LIVECDFILE}.iso" > "${LIVECDFILE}.md5sum" || exit 1
    sha256sum "${LIVECDFILE}.iso" > "${LIVECDFILE}.sha256sum" || exit 1
    sha512sum "${LIVECDFILE}.iso" > "${LIVECDFILE}.sha512sum" || exit 1
    popd || exit 1
fi

fi
