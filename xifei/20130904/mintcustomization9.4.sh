#Mint ISO自动定制脚本
#注意：
#1、脚本需要su root之后执行。
USERNAME=sil-172
MINTISODIR=/home/${USERNAME}/Downloads
LIVECDDIR=/home/${USERNAME}/livecdtmp
DESTISODIR=/home/${USERNAME}/Documents/ISO
ISONAME=linuxmint-15-cinnamon-dvd-32bit.iso
STARTTIME=`date +%Y%m%d-%H.%M`

echo "==创建构建目录=="
if [ -e "${LIVECDDIR}" ]; then
    rm -rf "${LIVECDDIR}"
fi
mkdir -p "${LIVECDDIR}"
cd ${LIVECDDIR}
if [ ! -e "${LIVECDDIR}/extract-cd" ]; then
    mkdir extract-cd
fi
if [ ! -e "${LIVECDDIR}/initrd.d" ]; then
    mkdir initrd.d
fi

echo "==获得镜像中的文件=="
cd ${LIVECDDIR}
umount /mnt
mount -o loop ${MINTISODIR}/${ISONAME} /mnt
cp -r /mnt/. extract-cd

echo "==initrd文件定制=="
cd ${LIVECDDIR}
cp extract-cd/casper/initrd.lz initrd.gz
gunzip -d initrd.gz
cd initrd.d
cpio -id < ../initrd
rm ../initrd
#initrd rebuild
find . | cpio --quiet --dereference -o -H newc > ../initrd
cd ${LIVECDDIR}
gzip initrd
mv initrd.gz extract-cd/casper/initrd.lz

echo "==squashfs文件定制=="
cd ${LIVECDDIR}
unsquashfs extract-cd/casper/filesystem.squashfs
#cd squashfs-root
#sudo chroot squashfs-root
#apt-get install 安装应用，进行定制操作
cd ${LIVECDDIR}
mksquashfs squashfs-root extract-cd/casper/filesystem.squashfs

echo "==修改casper文件夹下配置文件filesystem.manifest、filesystem.manifest-desktop、filesystem.size=="
chroot squashfs-root/ dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop
printf $(sudo du -sx --block-size=1 squashfs-root | cut -f1) > extract-cd/casper/filesystem.size

echo "==修改extract-cd下的配置文件md5sum.txt=="
cd ${LIVECDDIR}/extract-cd
find . -type f -print0 | xargs -0 md5sum > md5sum.txt

echo "==在extract-cd文件夹下生成镜像，镜像默认放到~/Documents/ISO文件夹下=="
if [ ! -e "${DESTISODIR}" ]; then
    mkdir -p "${DESTISODIR}"
fi
cd ${LIVECDDIR}/extract-cd
mkisofs -r -V "iscas mint" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "${DESTISODIR}/iscasmint-1.0-i386-${STARTTIME}.iso" .
