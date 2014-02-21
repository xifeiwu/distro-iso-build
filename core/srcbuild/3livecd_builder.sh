sudo apt-get install syslinux squashfs-tools genisoimage mkisofs

IMAGE_NAME="cossrcrebuilder"
isofile="cossrcrebuilder-"`date +%Y%m%d%H%M`.iso

cd work #

mkdir -p image/casper
mkdir -p image/isolinux
mkdir -p image/install

sudo cp chroot/boot/vmlinuz-3.8.0-19-generic image/casper/vmlinuz
sudo cp chroot/boot/initrd.img-3.8.0-19-generic image/casper/initrd.lz
#拷贝isolinux和sbm
sudo cp /usr/lib/syslinux/isolinux.bin image/isolinux/ # 
cp /boot/memtest86+.bin image/install/memtest # 
cp /boot/sbm.img image/install/  
cp ../assets/isolinux.txt image/isolinux #
cp ../assets/isolinux.cfg image/isolinux #

#创建manifest
sudo chroot chroot dpkg-query -W --showformat='${Package} ${Version}\n' | sudo tee image/casper/filesystem.manifest

sudo cp -v image/casper/filesystem.manifest image/casper/filesystem.manifest-desktop
REMOVE='casper gparted libdebian-installer4 lupin-casper ubiquity ubiquity-casper ubiquity-frontend-gtk ubiquity-slideshow-mint ubiquity-ubuntu-artwork user-setup'
for i in $REMOVE
do
        sudo sed -i "/${i}/d" image/casper/filesystem.manifest-desktop
done

#压缩chroot

sudo mksquashfs chroot image/casper/filesystem.squashfs
printf $(sudo du -sx --block-size=1 chroot | cut -f1) > image/casper/filesystem.size

#创建diskdefines
sudo cp ../assets/README.diskdefines image/README.diskdefiness
touch image/ubuntu
 
mkdir image/.disk
cd image/.disk
touch base_installable
echo "full_cd/single" > cd_type
echo 'Mint 15 "Raring" - i386' > info # need modify
echo "http://www.linuxmint.com/rel_olivia.php" > release_notes_url # neet to modify
cd ../..
cd image

sudo find . -type f -print0 | xargs -0 md5sum | grep -v "\./md5sum.txt" > md5sum.txt
sudo mkisofs -r -V "$IMAGE_NAME" -cache-inodes -J -l -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -o ../$isofile .
cd ..
