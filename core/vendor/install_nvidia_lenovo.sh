function intnvidiadriver()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    if [ ! -d $OUT/out/squashfs-root ] ; then
        echo You should make sure the uniso command has been executed successfully.
        return 1
    fi
    if [ ! -d $OUT/$PREAPP/drivers/nvidia-lenovo ] ; then
        echo You should make sure nvidia drivers dir exists.
        return 1
    fi

    echo The driver in $OUT/$PREAPP/drivers/nvidia-lenovo  will be installed into root path: $OUT/out/squashfs-root

    if [ -e $OUT/out/squashfs-root/tmp/nvidia_drivers ] ; then
        sudo umount $OUT/out/squashfs-root/tmp/nvidia_drivers
    else
        sudo mkdir $OUT/out/squashfs-root/tmp/nvidia_drivers
    fi
    sudo mount --bind $OUT/$PREAPP/drivers/nvidia-lenovo $OUT/out/squashfs-root/tmp/nvidia_drivers

    echo Install driver of nvidia drivers for lenovo
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd /tmp/nvidia_drivers && dpkg -i *.deb"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "update-initramfs -u"

    sudo umount $OUT/out/squashfs-root/tmp/nvidia_drivers
    sudo rmdir $OUT/out/squashfs-root/tmp/nvidia_drivers
    echo Finish installing driver of nvidia drivers for lenovo
}
