#!/bin/bash

FECHA="$(date +%Y%m%d)"

export red="\e[0;91m"
export blue="\e[0;94m"
export green="\e[0;92m"
export purple="\e[1;95m"
export white="\e[0;97m"
#export blackbg="\e[0;40m"
export bold="\e[1m"
export reset="\e[0m"

echo -e "${green}${bold}Iniciando proceso...${reset}"
echo -e "${green}${bold}Generando estructura de directorios de Imagen Viva...${reset}"
mkdir -p /tmp/aldos-liveimg/LiveOS
mkdir -p /tmp/aldos-liveimg/isofs
echo -e "${green}${bold}Generando estructura de directorios de Squashfs...${reset}"
mkdir -p /tmp/aldos-liveimg/squashfs/LiveOS
echo -e "${green}${bold}Generando estructura de directorios de Rootfs...${reset}"
mkdir -p /tmp/aldos-liveimg/rootfs

echo -e "${green}${bold}Desactivando (temporalmente) montaje automático de unidades de almacenamiento...${reset}"
cat << EOF > /tmp/90-udisks-inhibit.rules
ACTION=="add|change", SUBSYSTEM=="block", ENV{UDISKS_IGNORE}="1"
EOF
udevadm control --reload && \
udevadm trigger --subsystem-match=block

echo -e "${green}${bold}Generando imagen de disco ext3fs.img...${reset}"
dd if="/dev/zero" of="/tmp/aldos-liveimg/squashfs/LiveOS/ext3fs.img" bs=4M count=2000 && \
mkfs.ext4 "/tmp/aldos-liveimg/squashfs/LiveOS/ext3fs.img" > /dev/null && \
fsck.ext4 -fyD "/tmp/aldos-liveimg/squashfs/LiveOS/ext3fs.img" > /dev/null || \
exit 1

echo -e "${green}${bold}Montando sistema de archivos imagen de disco temporal...${reset}"
pushd /tmp/aldos-liveimg || :

mount -o loop -t ext4 "squashfs/LiveOS/ext3fs.img" "/tmp/aldos-liveimg/rootfs" && \
mkdir -p rootfs/dev && \
mkdir -p rootfs/proc && \
mkdir -p rootfs/sys && \
mount -o bind /dev rootfs/dev && \
mount -o bind /proc rootfs/proc && \
mount -o bind /sys rootfs/sys || \
exit 1

service cups stop

echo -e "${green}${bold}Instalando paquetes esenciales...${reset}"
yum \
    -y install \
    --installroot="$(pwd)/rootfs" \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd \
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
    vim-filesystem.noarch

echo -e "${green}${bold}Instalando paquetería de acuerdo al archivo PAQUETES.txt...${reset}"

cat "/home/jbarrios/Proyectos/ALDOS-LiveCD/PAQUETES.txt" | xargs yum \
    -y install \
    --installroot=/tmp/aldos-liveimg/rootfs \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd || exit 1

cat << EOF > rootfs/etc/yum.repos.d/ALDOS-livecd.repo
[ALDOS-livecd]
name=ALDOS LiveOS 14 - x86_64
baseurl=http://mirror0.alcancelibre.org/aldos/1.4/livecd/x86_64/
gpgkey=file:///etc/pki/rpm-gpg/AL-RPM-KEY
gpgcheck=1
enabled=0

[ALDOS-livecd-source]
name=ALDOS LiveOS source 14 - x86_64
baseurl=http://mirror0.alcancelibre.org/aldos/1.4/livecd/source/
gpgkey=file:///etc/pki/rpm-gpg/AL-RPM-KEY
gpgcheck=1
enabled=0

EOF

for GROUP in core base printing hardware-support x11 xfce-desktop xfce-desktop xfce-apps xfce-extra-plugins sound-and-video x11
do
  yum \
    -y \
    --installroot="$(pwd)/rootfs/" \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd \
    group mark install ${GROUP}
done

yum \
    -y install \
    --installroot="$(pwd)/rootfs/" \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd \
    calamares.x86_64 \
    calamares-libs.x86_64 \
    calamares-livesys.noarch

# Personalizar sistema
echo -e "${green}${bold}Configurando sistema de identificación y recursos de autenticación...${reset}"
echo -e "${green}${bold}Estableciendo spinfinity como tema para Plymouth...${reset}"
echo -e "${green}${bold}Regenerando initramfs...${reset}"
echo -e "${green}${bold}Creando configuración de grub2...${reset}"
echo -e "${green}${bold}Generando machine-id...${reset}"
echo -e "${green}${bold}Eliminando contraseña de 'root'...${reset}"
echo -e "${green}${bold}Generando grupos de usuarios adicionales...${reset}"
echo -e "${green}${bold}Ajustes menores...${reset}"
echo -e "${green}${bold}Limpieza de base de datos RPM y YUM...${reset}"
cat << EOF > rootfs/sbin/setup-aldos.sh
/usr/bin/authselect select sssd --force
/usr/bin/authselect check
/usr/sbin/plymouth-set-default-theme spinfinity
/sbin/dracut -f
/usr/sbin/grub2-mkconfig -o /boot/grub2/grub.cfg
/usr/sbin/grub2-mkconfig -o /boot/efi/EFI/aldos/grub.cfg
/bin/dbus-uuidgen > /var/lib/dbus/machine-id
/usr/bin/passwd -f -u root
/usr/bin/passwd -d root
/usr/sbin/groupadd -r gamemode
/usr/sbin/groupadd -r vboxusers
/bin/chown polkitd /etc/polkit-1/rules.d
/bin/chown polkitd /usr/share/polkit-1/rules.d
/usr/bin/rpmorphan -add-keep libertas-firmware
/bin/touch /etc/resolv.conf
rm -f /etc/yum.repos.d/ALDOS-livecd.repo
/bin/rm -fr /var/lib/yum/{groups,history,repos,rpmdb-indexes,uuid,yumdb}
/bin/rm -fr /var/cache/yum/*
/bin/mkdir -p /var/lib/yum/{history,yumdb}
rm -f /var/lib/rpm/__db*
echo "/dev/root  /         ext4    defaults,noatime,nodiratime,commit=30,data=writeback 0 0" > /etc/fstab
/bin/rm -f /1
/bin/rm -f /sbin/setup-aldos.sh
EOF

chmod +x /tmp/
chroot rootfs/ /sbin/setup-aldos.sh
rm -f rootfs/sbin/setup-aldos.sh

mkdir -p rootfs/boot/efi/System/Library/CoreServices
cat << EOF > "/tmp/aldos-liveimg/rootfs/boot/efi/System/Library/CoreServices/SystemVersion.plist"
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
        <key>ProductBuildVersion</key>
        <string>${FECHA}</string>
        <key>ProductName</key>
        <string>Linux</string>
        <key>ProductVersion</key>
        <string>ALDOS 1.4.19</string>
</dict>
EOF

popd || exit 1

pushd /tmp/aldos-liveimg/rootfs || exit 1
echo -e "${green}${bold}Desactivando SELinux...${reset}"
sed -i \
    -e "s|SELINUX=.*|SELINUX=disabled|g" \
    etc/sysconfig/selinux

echo -e "${green}${bold}Configurando idioma y teclado...${reset}"

echo -e "${green}${bold}Modificando /etc/locale.conf y /etc/environment...${reset}"
sed -i \
    -e "s|LANG=.*|LANG=\"es_MX.UTF-8\"|g" \
    -e "s|LC_ALL=.*|LC_ALL=\"es_MX.UTF-8\"|g" \
    -e "s|SYSFONT=.*|SYSFONT=\"latarcyrheb-sun16\"|g" \
    etc/locale.conf \
    etc/environment || exit 1

echo -e "${green}${bold}Modificando /etc/vconsole.conf...${reset}"
sed -i \
    -e "s|LAYOUT=.*|LAYOUT=\"es\"|g" \
    -e "s|KEYTABLE=.*|LAYOUT=\"es\"|g" \
    -e "s|KEYMAP=.*|KEYMAP=\"es\"|g" \
    -e "s|FONT=.*|FONT=\"latarcyrheb-sun16\"|g" \
    etc/vconsole.conf || exit 1

echo -e "${green}${bold}Modificando /etc/rc.d/init.d/livesys...${reset}"
sed -i \
    -e "s|value=\"es\"|value=\"es\"|g" \
    etc/rc.d/init.d/livesys || exit 1

echo -e "${green}${bold}Modificando /etc/default/grub...${reset}"
sed -i \
    -e "s|rd.locale.LANG=.*|rd.locale.LANG=es_MX.UTF-8|g" \
    -e "s|rd.vconsole.keymap=.*|rd.vconsole.keymap=es|g" \
    -e "s|rd.vconsole.font=.*|rd.vconsole.font=latarcyrheb-sun16|g" \
    etc/default/grub || exit 1

# Nombre de anfitrión predeterminado
echo -e "${green}${bold}Estableciendo nombre de anfitrión del sistema...${reset}"
echo -e "${green}${bold}Modificando archivo de legado /etc/sysconfig/network...${reset}"
sed -i \
    -e "s|HOSTNAME=.*|HOSTNAME=\"aldos-liveimg\"|g" \
    etc/sysconfig/network || exit 1

echo -e "${green}${bold}Modificando /etc/hostname...${reset}"
echo "aldos-liveimg" > etc/hostname || exit 1

echo -e "${green}${bold}Modificando /etc/hosts...${reset}"
echo -e "127.0.0.1    aldos-liveimg\n::1    aldos-liveimg" >> etc/hosts

echo -e "${green}${bold}Copiando archivos necesarios para el arranque de la imagen viva...${reset}"
mkdir -p /tmp/aldos-liveimg/isofs/isolinux
cp -av \
    boot/vmlinuz-*.x86_64 \
    "/tmp/aldos-liveimg/isofs/isolinux/vmlinuz" || exit 1

cp -av \
    boot/initramfs-*.img \
    "/tmp/aldos-liveimg/isofs/isolinux/initrd.img" || exit 1

cp -av \
    usr/share/syslinux/isolinux.bin \
    "/tmp/aldos-liveimg/isofs/isolinux/isolinux.bin" || exit 1

cp -av \
    usr/share/syslinux/vesamenu.c32 \
    "/tmp/aldos-liveimg/isofs/isolinux/vesamenu.c32" || exit 1

popd || exit 1

pushd /tmp/aldos-liveimg/isofs/isolinux || exit 1
sha512hmac vmlinuz > .vmlinuz.hmac
popd || exit 1

cp -av \
    "/home/jbarrios/Proyectos/ALDOS-LiveCD/splash.jpg" \
    "/tmp/aldos-liveimg/isofs/isolinux/splash.jpg" || exit 1

cp -av \
    "/home/jbarrios/Proyectos/ALDOS-LiveCD/LEEME.txt" \
    "/tmp/aldos-liveimg/isofs/isolinux/LEEME.txt" || exit 1

cp -av \
    "/home/jbarrios/Proyectos/ALDOS-LiveCD/Licencia.txt" \
    "/tmp/aldos-liveimg/isofs/isolinux/Licencia.txt" || exit 1

pushd /tmp/aldos-liveimg/isofs || exit 1

echo -e "${green}${bold}Creando configuración de gestor de arranque SysLinux...${reset}"
# Crear el menú de SysLinux (gestor de arranque del LiveCD)
cat << EOF > isolinux/isolinux.cfg
default vesamenu.c32
timeout 500

menu background splash.jpg
menu title Bienvenido a ALDOS 1.4.19!
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
  menu label ALDOS 1.4.19 - Sistema Vivo/Instalar sistema
  kernel vmlinuz
  append initrd=initrd.img root=live:CDLABEL=ALDOS-1-4-19 rootfstype=auto ro liveimg rd.locale.LANG=es_MX.UTF-8 KEYBOARDTYPE=pc SYSFONT=latarcyrheb-sun16 rd.vconsole.keymap=es rootflags=defaults,relatime,commit=60 selinux=0 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM noswap quiet splash
menu default
label linux1
  menu label ALDOS 1.4.19 - Modo seguro
  kernel vmlinuz
  append initrd=initrd.img root=live:CDLABEL=ALDOS-1-4-19 rootfstype=auto ro liveimg rd.locale.LANG=es_MX.UTF-8 KEYBOARDTYPE=pc SYSFONT=latarcyrheb-sun16 rd.vconsole.keymap=es rootflags=defaults,relatime,commit=60 selinux=0 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM rd_NO_PLYMOUTH=1 xdriver=vesa nomodeset noswap quiet
label check0
  menu label ALDOS 1.4.19 - Modo verificar e Iniciar
  kernel vmlinuz
  append initrd=initrd.img root=live:CDLABEL=ALDOS-1-4-19 rootfstype=auto ro liveimg rd.locale.LANG=es_MX.UTF-8 KEYBOARDTYPE=pc SYSFONT=latarcyrheb-sun16 rd.vconsole.keymap=es rootflags=defaults,relatime,commit=60 selinux=0 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM check noswap quiet splash
label local
  menu label Iniciar desde unidad local
  localboot 0xffff
EOF

######################################################################
######################################################################
######################################################################
######################################################################
######################################################################
#### TODO: EFI Stuff.
mkdir -p boot/grub/ images/pxeboot/
ln -f isolinux/vmlinuz images/pxeboot/vmlinuz
ln -f isolinux/initrd.img images/pxeboot/initrd.img
cat << EOF > boot/grub/grub.cfg
set default="0"

function load_video {
  insmod all_video
}

load_video
set gfxpayload=keep
insmod gzio
insmod part_msdos
insmod part_gpt
insmod ext2
insmod chain
insmod gfxmenu
set gfxmode=1024x768x32
insmod efi_gop
insmod efi_uga
insmod video_bochs
insmod video_cirrus
insmod gfxterm
insmod jpeg
insmod png
terminal_output gfxterm
loadfont /boot/grub/themes/system/DejaVuSans-10.pf2
loadfont /boot/grub/themes/system/DejaVuSans-12.pf2
loadfont /boot/grub/themes/system/DejaVuSans-Bold-14.pf2
loadfont /boot/grub/fonts/unicode.pf2
set theme=/boot/grub/themes/system/theme.txt

set timeout=60
### END /etc/grub.d/00_header ###

search --no-floppy --set=root -l 'ALDOS-1-4-19'

### BEGIN /etc/grub.d/10_linux ###
menuentry 'ALDOS 1.4.19 - Sistema Vivo/Instalar sistema' --class aldos --class gnu-linux --class gnu --class os {
	linux /images/pxeboot/vmlinuz root=live:CDLABEL=ALDOS-1-4-19 rootfstype=auto ro liveimg rd.locale.LANG=es_MX.UTF-8 KEYBOARDTYPE=pc SYSFONT=latarcyrheb-sun16 rd.vconsole.keymap=es rootflags=defaults,relatime,commit=60 selinux=0 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM noswap quiet splash
	initrd /images/pxeboot/initrd.img
}
menuentry 'ALDOS 1.4.19 - Modo verificar medio e Iniciar' --class aldos --class gnu-linux --class gnu --class os {
	linux /images/pxeboot/vmlinuz root=live:CDLABEL=ALDOS-1-4-19 rootfstype=auto ro liveimg rd.locale.LANG=es_MX.UTF-8 KEYBOARDTYPE=pc SYSFONT=latarcyrheb-sun16 rd.vconsole.keymap=es rootflags=defaults,relatime,commit=60 selinux=0 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM check noswap quiet splash
	initrd /images/pxeboot/initrd.img
}
submenu 'Solucionar Problemas -->' {
	menuentry 'ALDOS 1.4.19 - Modo seguro' --class aldos --class gnu-linux --class gnu --class os {
		linux /images/pxeboot/vmlinuz root=live:CDLABEL=ALDOS-1-4-19 rootfstype=auto ro liveimg rd.locale.LANG=es_MX.UTF-8 KEYBOARDTYPE=pc SYSFONT=latarcyrheb-sun16 rd.vconsole.keymap=es rootflags=defaults,relatime,commit=60 selinux=0 nmi_watchdog=0 rd_NO_LUKS rd_NO_MD rd_NO_DM rd_NO_PLYMOUTH=1 xdriver=vesa nomodeset noswap quiet
		initrd /images/pxeboot/initrd.img
	}
	menuentry 'Iniciar 1ra unidad local' --class fedora --class gnu-linux --class gnu --class os {
		chainloader (hd0)+1
	}
	menuentry 'Iniciar 2da unidad local' --class fedora --class gnu-linux --class gnu --class os {
		chainloader (hd1)+1
	}
}
EOF

######################################################################
######################################################################
######################################################################
######################################################################
######################################################################

cp -a /home/jbarrios/Proyectos/ALDOS-LiveCD/LEEME.txt /tmp/aldos-liveimg/isofs/LEEME.txt
cp -a /home/jbarrios/Proyectos/ALDOS-LiveCD/Licencia.txt /tmp/aldos-liveimg/isofs/Licencia.txt

touch aldos
mkdir .disk && \
touch .disk/base_installable && \
echo "full_cd/single" > .disk/cd_type && \
echo "ALDOS 1.4.19 ${FECHA}" > .disk/info && \
echo "https://www.alcancelibre.org/noticias/disponible-aldos-1-4-19" > .disk/release_notes_url 
popd || exit 1

# Desmontar sistemas de archivos
echo -e "${green}${bold}Desmontando sistemas de archivos virtuales de imagen de disco...${reset}"
killall cupsd || :
pushd /tmp/aldos-liveimg/
sync
umount rootfs/sys && \
umount rootfs/proc && \
umount rootfs/dev && \
umount rootfs || \
exit 1
popd || exit 1

losetup --detach-all || :

rm -f /lib/udev/rules.d/90-udisks-inhibit.rules
udevadm control --reload
udevadm trigger --subsystem-match=block

echo -e "${green}${bold}Verificando sistema de archivos de imagen de disco...${reset}"
pushd /tmp/aldos-liveimg/ || exit 1
fsck.ext4 -fyD squashfs/LiveOS/ext3fs.img
fsck.ext4 -p squashfs/LiveOS/ext3fs.img
zerofree -v squashfs/LiveOS/ext3fs.img
blockdev -q --getsz squashfs/LiveOS/ext3fs.img
popd || exit 1

echo -e "${green}${bold}Creando imagen de disco comprimida con Squashfs...${reset}"
pushd /tmp/aldos-liveimg/ || exit 1
mkdir -p isofs/LiveOS/
rm -f isofs/LiveOS/squashfs.img
mksquashfs \
    squashfs \
    isofs/LiveOS/squashfs.img \
    -quiet -comp xz -b 16384 -Xdict-size 100%
popd || exit 1

echo -e "${green}${bold}Generando archivo de sumas MD5...${reset}"
pushd /tmp/aldos-liveimg/isofs || exit 1
rm -f md5sum.txt
find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt
popd || exit 1

pushd /home/jbarrios/Proyectos/ALDOS-LiveCD/ || :
echo -e "${green}${bold}Creando imagen ISO final...${reset}"
#     -no-emul-boot \
#    -efi-boot EFI/BOOT/grubx64.efi \
#genisoimage \
#    -no-emul-boot \
#    -boot-load-size 4 \
#    -boot-info-table \
#    -eltorito-boot isolinux/isolinux.bin \
#    -eltorito-catalog isolinux/boot.cat \
#    -eltorito-alt-boot \
#    -joliet \
#    -joliet-long \
#    -rock \
#    -rational-rock \
#    -full-iso9660-filenames \
#    -allow-limited-size \
#    -udf \
#    -input-charset utf-8 \
#    -sysid LINUX \
#    -volid ALDOS-1-4-19 \
#    -copyright Licencia.txt \
#    -publisher "Joel Barrios" \
#    -md5-list md5sum.txt \
#    -o ALDOS-1.4.19-x86_64-${FECHA}.iso \
#    isofs/ && isohybrid ISOS/ALDOS-1.4.19-x86_64-${FECHA}.iso

BOOT_IMG_DATA=$(mktemp -d)
BOOT_IMG=$(mktemp -d)/efi.img

mkdir -p $(dirname ${BOOT_IMG})

truncate -s 8M ${BOOT_IMG}
mkfs.vfat ${BOOT_IMG}
mount ${BOOT_IMG} ${BOOT_IMG_DATA}
mkdir -p ${BOOT_IMG_DATA}/efi/boot

grub-mkimage \
    -C xz \
    -O x86_64-efi \
    -p /boot/grub \
    -o ${BOOT_IMG_DATA}/efi/boot/bootx64.efi \
    boot linux search normal configfile \
    part_gpt btrfs ext2 fat iso9660 loopback \
    test keystatus gfxmenu regexp probe \
    efi_gop efi_uga all_video gfxterm font \
    echo read ls cat png jpeg halt reboot

umount ${BOOT_IMG_DATA}
rm -rf ${BOOT_IMG_DATA}

mv ${BOOT_IMG} isofs/

rm -f ISOS/ALDOS-1.4.19-x86_64-${FECHA}.iso && \
grub2-mkrescue \
    --locales=es \
    --product-name=ALDOS \
    --product-version=1.4.19 \
    --themes=system \
    -o ISOS/ALDOS-1.4.19-x86_64-${FECHA}.iso \
    isofs/ && \
xorriso \
    -dev ALDOS-1.4.19-x86_64-${FECHA}.iso \
    -volid 'ALDOS-1-4-19' \
    -publisher 'Joel Barrios' \
    -abstract_file 'LEEME.txt' \
    -copyright_file 'LICENCIA.txt' \
    -commit && \
fdisk -l ISOS/ALDOS-1.4.19-x86_64-${FECHA}.iso && \
isoinfo -d -i ISOS/ALDOS-1.4.19-x86_64-${FECHA}.iso

md5sum ALDOS-1.4.19-x86_64-${FECHA}.iso > ALDOS-1.4.19-x86_64-${FECHA}.md5sum
sha256sum ALDOS-1.4.19-x86_64-${FECHA}.iso > ALDOS-1.4.19-x86_64-${FECHA}.sha256sum
sha512sum ALDOS-1.4.19-x86_64-${FECHA}.iso > ALDOS-1.4.19-x86_64-${FECHA}.sha512sum
chown jbarrios:jbarrios ALDOS-1.4.19-x86_64-${FECHA}.*
du -sh ALDOS-1.4.19-x86_64-${FECHA}.*

popd || exit 1

