cd work #

#绑定/dev
sudo mount --bind /dev chroot/dev
sudo cp /etc/hosts chroot/etc/hosts
sudo cp /etc/resolv.conf chroot/etc/resolv.conf
sudo cp ../official-package-repositories.list chroot/etc/apt/sources.list
sudo cp ../preferences chroot/etc/apt/preferences
sudo cp ../99myown chroot/etc/apt/apt.conf.d/99myown

#备份chroot里的/sbin/initctl
sudo chroot chroot /bin/bash -c "sudo cp /sbin/initctl /sbin/initctl.bak"
sudo chroot chroot /bin/bash -c "mount none -t proc /proc"
sudo chroot chroot /bin/bash -c "mount none -t sysfs /sys"
sudo chroot chroot /bin/bash -c "mount none -t devpts /dev/pts"
sudo chroot chroot /bin/bash -c "export HOME=/root"
sudo chroot chroot /bin/bash -c "export LC_ALL=C"
sudo chroot chroot /bin/bash -c "apt-get update"
sudo chroot chroot /bin/bash -c "apt-get install --yes dbus" # ???
sudo chroot chroot /bin/bash -c "dbus-uuidgen > /var/lib/dbus/machine-id"
sudo chroot chroot /bin/bash -c "dpkg-divert --local --rename --add /sbin/initctl"
sudo chroot chroot /bin/bash -c "ln -s /bin/true /sbin/initctl"


# stage1
echo "------------------------------stage1------------------------------------------"
while read list
do
        pkgsname=`echo $list | awk '{print $1}'`
        sudo chroot chroot /bin/bash -c "apt-get install --yes --allow-unauthenticated ${pkgsname}"
        if [ $? -ne 0 ];then
                echo $pkgsname >> fail_stage1
        fi
done < ../filesystem.manifest

# stage1.1 install close source pkgs (Third party packages not in official)
echo "------------------------------stage1.1------------------------------------------"
sudo mkdir chroot/3rdpart
sudo cp ../3rdpart/*.deb chroot/3rdpart
sudo chroot chroot /bin/bash -c "cd 3rdpart && dpkg -i *.deb"
sudo chroot chroot /bin/bash -c "rm -rf 3rdpart"

# stage 2
echo "------------------------------stage2------------------------------------------"
while read pkgsname
do
        sudo chroot chroot /bin/bash -c "apt-get install --yes --allow-unauthenticated ${pkgsname}"
        if [ $? -ne 0 ];then
                echo $pkgsname >> fail_stage2
        fi
done < fail_stage1

# stage3 force install
echo "------------------------------stage3------------------------------------------"
while read pkgsname
do
        sudo chroot chroot /bin/bash -c "apt-get install --yes --force-yes --allow-unauthenticated ${pkgsname}"
        if [ $? -ne 0 ];then
                echo $pkgsname >> fail_stage3
        fi
done < fail_stage2

# clean unnecessary packages
echo "-----------apt-get autoremove, clean unnecessary dependency packages---------"
# autoremove is used to remove packages that were automatically installed to satisfy dependencies for other packages and are now no longer needed.
sudo chroot chroot /bin/bash -c "apt-get autoremove"
sudo chroot chroot /bin/bash -c "apt-get clean"

#清理ChRoot环境
sudo chroot chroot /bin/bash -c "rm /etc/apt/sources.list"
sudo chroot chroot /bin/bash -c "rm /etc/apt/preferences"
sudo chroot chroot /bin/bash -c "rm /etc/apt/apt.conf.d/99myown"

sudo chroot chroot /bin/bash -c "rm /var/lib/dbus/machine-id"
sudo chroot chroot /bin/bash -c "rm /sbin/initctl"
sudo chroot chroot /bin/bash -c "dpkg-divert --rename --remove /sbin/initctl"
sudo chroot chroot /bin/bash -c "apt-get clean"
sudo chroot chroot /bin/bash -c "rm -rf /tmp/*"
sudo chroot chroot /bin/bash -c "rm /etc/resolv.conf"
sudo chroot chroot /bin/bash -c "umount -lf /proc"
sudo chroot chroot /bin/bash -c "umount -lf /sys"
sudo chroot chroot /bin/bash -c "umount -lf /dev/pts"
sudo chroot chroot /bin/bash -c "exit"
sudo umount -l chroot/dev


