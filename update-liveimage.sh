#!/bin/bash

FECHA="$(date +%Y%m%d)"
export FECHA

pushd /home/jbarrios/Proyectos/ALDOS-LiveCD/aldos-liveimg/ || exit 1
fsck.ext4 -p   squashfs/LiveOS/ext3fs.img && \
fsck.ext4 -fyD squashfs/LiveOS/ext3fs.img && \
fsck.ext4 -p   squashfs/LiveOS/ext3fs.img && \
mount -o loop -t ext4 squashfs/LiveOS/ext3fs.img rootfs && \
mount -o bind /dev  rootfs/dev && \
mount -o bind /proc rootfs/proc && \
mount -o bind /sys  rootfs/sys || exit 1

cp -a /home/jbarrios/Proyectos/ALDOS-LiveCD/ALDOS-livecd.repo rootfs/etc/yum.repos.d/ALDOS-livecd.repo
yum -y --installroot="$(pwd)/rootfs/" --disablerepo=* --enablerepo=ALDOS-livecd update
# yum -y --installroot="$(pwd)/rootfs/" --disablerepo=* --enablerepo=ALDOS-livecd install kmod-VirtualBox
# yum -y --installroot="$(pwd)/rootfs/" --disablerepo=* --enablerepo=ALDOS-livecd remove xxxx

for GROUP in core base printing hardware-support x11 xfce-desktop xfce-desktop xfce-apps xfce-extra-plugins sound-and-video x11
do
  yum \
    -y \
    --installroot="$(pwd)/rootfs/" \
    --disablerepo=* \
    --enablerepo=ALDOS-livecd \
    group mark install ${GROUP}
done

rm -f  rootfs/etc/yum.repos.d/ALDOS-livecd.repo
rm -fr rootfs/var/lib/yum/{groups,history,repos,rpmdb-indexes,uuid,yumdb}
rm -fr rootfs/var/cache/yum/*
rm -f  rootfs/var/lib/rpm/__db*
mkdir -p rootfs/var/lib/yum/{history,yumdb}
echo > rootfs/root/.bash_history

sync && \
umount rootfs/sys && \
umount rootfs/proc && \
umount rootfs/dev && \
umount rootfs || exit 1

# blockdev -q --getsz /dev/loop0 || exit 1
zerofree  -v   squashfs/LiveOS/ext3fs.img && \
fsck.ext4 -fyD squashfs/LiveOS/ext3fs.img && \
fsck.ext4 -p   squashfs/LiveOS/ext3fs.img || exit 1

# losetup -f
# losetup /dev/loop0 squashfs/LiveOS/ext3fs.img -r
# ln -s /dev/loop0 /dev/mapper/live-rw
#
# losetup -d /dev/loop0
# rm -f /dev/mapper/live-rw

rm -f isofs/LiveOS/squashfs.img && \
mksquashfs \
    squashfs \
    isofs/LiveOS/squashfs.img \
    -quiet -comp xz -b 16384 -Xdict-size 100% || exit 1

chown -R jbarrios:jbarrios isofs/ squashfs/

popd || exit 1

# pushd /home/jbarrios/Proyectos/ALDOS-LiveCD/aldos-liveimg/efifs || exit 1
# grub2-mkimage -o EFI/BOOT/bootx64.efi -p /EFI/BOOT/ -O x86_64-efi fat iso9660 part_gpt part_msdos normal boot linux configfile loopback chain efifwsetup efi_gop efi_uga ls search search_label search_fs_uuid search_fs_file gfxterm gfxterm_background gfxterm_menu test all_video loadenv exfat ext2 ntfs btrfs hfsplus udf && \
# chmod +x EFI/BOOT/bootx64.efi
# dd if=/dev/zero of=boot/grub2/efiboot.img bs=1M count=10
# mkfs.vfat boot/grub2/efiboot.img
# mmd -i boot/grub2/efiboot.img EFI
# mmd -i boot/grub2/efiboot.img EFI/BOOT
# mcopy -i boot/grub2/efiboot.img EFI/BOOT/bootx64.efi ::EFI/BOOT/bootx64.efi
# chown -R jbarrios:jbarrios .
# popd || exit 1
#
# pushd /home/jbarrios/Proyectos/ALDOS-LiveCD/aldos-liveimg/ || exit 1
# rsync -avz -H -P --delete efifs/boot/ isofs/boot/ || exit 1
# rsync -avz -H -P --delete efifs/EFI/ isofs/EFI/ || exit 1
# popd || exit 1

pushd /home/jbarrios/Proyectos/ALDOS-LiveCD/aldos-liveimg/isofs/ || exit 1

rm -f md5sum.txt; find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt

popd || exit 1

pushd /home/jbarrios/Proyectos/ALDOS-LiveCD/aldos-liveimg/ || exit 1
chown -R jbarrios:jbarrios isofs/
mkdir -p ISOS

FECHA="$(date +%Y%m%d)"
export FECHA
rm -f ISOS/ALDOS-1.4.19-x86_64-${FECHA}.iso && \
xorriso -as mkisofs -graft-points \
  -V 'ALDOS-1-4-19' \
  -publisher 'Joel Barrios' \
  -abstract 'LEEME.txt' \
  -copyright 'LICENCIA.txt' \
  --md5 \
  -b boot/grub/i386-pc/eltorito.img \
  -no-emul-boot -boot-load-size 4 -boot-info-table \
  --grub2-boot-info --grub2-mbr /usr/lib/grub/i386-pc/boot_hybrid.img \
  --efi-boot efi.img -efi-boot-part --efi-boot-image \
  --protective-msdos-label -o ISOS/ALDOS-1.4.19-x86_64-${FECHA}.iso -r \
  --sort-weight 0 / --sort-weight 1 /boot isofs/ efifs/ && \
fdisk -l ISOS/ALDOS-1.4.19-x86_64-${FECHA}.iso && \
isoinfo -d -i ISOS/ALDOS-1.4.19-x86_64-${FECHA}.iso && \
xorriso -indev ISOS/ALDOS-1.4.19-x86_64-${FECHA}.iso -report_el_torito as_mkisofs || exit 1

pushd ISOS/ || exit 1
md5sum ALDOS-1.4.19-x86_64-${FECHA}.iso > ALDOS-1.4.19-x86_64-${FECHA}.md5sum && \
sha256sum ALDOS-1.4.19-x86_64-${FECHA}.iso > ALDOS-1.4.19-x86_64-${FECHA}.sha256sum && \
sha512sum ALDOS-1.4.19-x86_64-${FECHA}.iso > ALDOS-1.4.19-x86_64-${FECHA}.sha512sum && \
chown jbarrios:jbarrios ALDOS-1.4.19-x86_64-${FECHA}.* && \
du -sh ALDOS-1.4.19-x86_64-${FECHA}.*
popd || exit 1

popd || exit 1
