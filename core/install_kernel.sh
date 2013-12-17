function intkernel()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    if [ ! "$KERNEL_VERSION" ] ; then
        echo "ERROR: No KERNEL_VERSION set."
        return 1
    fi
    sudo cp $T/kernel/$KERNEL_VERSION/linux-headers-${KERNEL_VERSION_FULL}*.deb $OUT/out/squashfs-root/
    sudo cp $T/kernel/$KERNEL_VERSION/linux-image-${KERNEL_VERSION_FULL}*.deb $OUT/out/squashfs-root/

    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg -i -E linux-image-${KERNEL_VERSION_FULL}*.deb linux-headers-${KERNEL_VERSION_FULL}*.deb"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "ln -s /usr/src/linux-headers-${KERNEL_VERSION_FULL} /lib/modules/${KERNEL_VERSION_FULL}/build"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd /lib/modules/${KERNEL_VERSION_FULL} && rm -rf kernel"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg -i linux-image-${KERNEL_VERSION_FULL}*.deb linux-headers-${KERNEL_VERSION_FULL}*.deb"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --purge linux-generic linux-headers-generic linux-image-generic linux-headers-3.8.0-19-generic linux-headers-3.8.0-19 linux-image-extra-3.8.0-19-generic linux-image-3.8.0-19-generic"
   sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm -rf /home/*"
   sudo chroot $OUT/out/squashfs-root /bin/bash -c "update-initramfs -u"

   sudo rm $OUT/out/squashfs-root/linux-headers-${KERNEL_VERSION_FULL}*.deb
   sudo rm $OUT/out/squashfs-root/linux-image-${KERNEL_VERSION_FULL}*.deb

   sudo cp $OUT/out/squashfs-root/boot/vmlinuz-${KERNEL_VERSION_FULL} $OUT/out/mymint/casper/vmlinuz
   sudo cp $OUT/out/squashfs-root/boot/initrd.img-${KERNEL_VERSION_FULL} $OUT/out/mymint/casper/initrd.lz
   echo "replace kernel successfull !"
}
