#Mint ISO自动定制脚本
#注意：
#1、很多命令都需要有sudo权限才能执行，执行的用户需要不输入密码的sudo权限。
MINTISODIR=~/Downloads
LIVECDDIR=~/livecdtmp
DESTISODIR=~/Documents/ISO
ISONAME=linuxmint-15-cinnamon-dvd-32bit.iso
USERNAME=sil-172
STARTTIME=`date +%Y-%m-%d-%H:%M`

if [ ! -e "${LIVECDDIR}" ]; then
    mkdir -p "${LIVECDDIR}"
fi
cd ${LIVECDDIR}
if [ ! -e "${LIVECDDIR}/mnt" ]; then
    mkdir mnt
fi
if [ ! -e "${LIVECDDIR}/extract-cd" ]; then
    mkdir extract-cd
fi
if [ ! -e "${LIVECDDIR}/initrd.d" ]; then
    mkdir initrd.d
fi

#echo "==镜像文件复制，略过。。。=="
#cp ${MINTISODIR}/${ISONAME} ${LIVECDDIR}

echo "==获得镜像中的文件=="
cd ${LIVECDDIR}
sudo mount -o loop ${MINTISODIR}/${ISONAME} mnt
rsync --exclude=/casper/filesystem.squashfs --exclude=/casper/initrd.lz -a mnt/ extract-cd
chmod +w extract-cd/casper

echo "==initrd文件定制=="
cp mnt/casper/initrd.lz initrd.gz
sudo gunzip -d initrd.gz
cd initrd.d
cpio -id < ../initrd
sudo rm ../initrd
#initrd rebuild
find . | cpio --quiet --dereference -o -H newc > ../initrd
cd ${LIVECDDIR}
gzip initrd
sudo rm -rf initrd.d/
mv initrd.gz extract-cd/casper/initrd.lz

echo "==squashfs文件定制=="
cd ${LIVECDDIR}
sudo unsquashfs mnt/casper/filesystem.squashfs
sudo chown ${USERNAME}.${USERNAME} -R squashfs-root
#cd squashfs-root
#sudo chroot squashfs-root
#apt-get install 安装应用，进行定制操作
#cd ${LIVECDDIR}
sudo mksquashfs squashfs-root/ filesystem.squashfs
mv filesystem.squashfs extract-cd/casper/

echo "==修改casper文件夹下配置文件filesystem.manifest、filesystem.manifest-desktop、filesystem.size=="
sudo rm extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sudo chroot squashfs-root/ dpkg-query -W --showformat='${Package} ${Version}\n' > extract-cd/casper/filesystem.manifest
cp extract-cd/casper/filesystem.manifest extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/ubiquity/d' extract-cd/casper/filesystem.manifest-desktop
sudo sed -i '/casper/d' extract-cd/casper/filesystem.manifest-desktop
sudo rm extract-cd/casper/filesystem.size
sudo printf $(sudo du -sx --block-size=1 squashfs-root | cut -f1) > extract-cd/casper/filesystem.size

echo "==修改extract-cd下的配置文件md5sum.txt=="
cd ${LIVECDDIR}/extract-cd
chmod +w md5sum.txt
find . -type f -print0 | xargs -0 md5sum > md5sum.txt

echo "==在extract-cd文件夹下生成镜像，镜像默认放到~/Documents/ISO文件夹下=="
if [ ! -e "${DESTISODIR}" ]; then
    mkdir -p "${DESTISODIR}"
fi
cd ${LIVECDDIR}/extract-cd
sudo mkisofs -r -V "iscas mint" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o "${DESTISODIR}/iscasmint-1.0-i386-(${STARTTIME}).iso" .

#重建完成后删除livecdtmp文件夹
cd ${LIVECDDIR}
sudo umount ${LIVECDDIR}/mnt
#sudo chmod +w -R ${LIVECDDIR}
#sudo chown ${USERNAME}.${USERNAME} -R ${LIVECDDIR} 
if [ -e "${LIVECDDIR}" ]; then
    sudo rm -rf "${LIVECDDIR}"
fi
