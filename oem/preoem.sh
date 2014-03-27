#安装oem相关软件包并对OEM安装进行预设,把此脚本放在build/oem/路径下,把app目录放在～/app下
set -e

CHROOTDIR=~/customize/mkiso_out/squashfs-root
DEBDIR=~/cdos-oem

if [ -z "$1" ] ; then
    echo error: No chrootdir setting at first param.
    exit -1
fi

if [ -z "$2" ] ; then
    echo error: No deb dir setting at second param.
    exit -1
fi

CURDIR=$(cd "$(dirname $0)"; pwd)
. $CURDIR/../set_version.sh
isodir=$OSNAME
CHROOTDIR=$1/squashfs-root
CDOSDIR=$1/$isodir
DEBDIR=$2/cdos-oem

if [ ! $OSVERSION ] ; then
    echo Error: no OSVERSION env set.
    exit -1
fi

if [ ! $OSVERSIONFULLNAME ] ; then
    echo Error: no OSVERSIONFULLNAME env set.
    exit -1
fi

if [ ! -e "${CHROOTDIR}" ]; then
    echo "squashfs-root not found"
    exit
fi

mkdir ${CHROOTDIR}/usr/share/oem
cp ${DEBDIR}/* ${CHROOTDIR}/usr/share/oem/

#********************start************************
sudo mount --bind /dev $CHROOTDIR/dev
sudo mount -t proc proc $CHROOTDIR/proc
#********************end**************************

chroot ${CHROOTDIR} /bin/bash -c "echo 'chroot to squashfs-root'"
chroot ${CHROOTDIR} /bin/bash -c "cd /usr/share/oem && dpkg -i -E bogl-bterm_0.1.18-8ubuntu1_i386.deb tasksel_2.88ubuntu14_all.deb tasksel-data_2.88ubuntu14_all.deb ubiquity-frontend-debconf_2.14.8-1linuxmint2_all.deb"
chroot ${CHROOTDIR} /bin/bash -c "apt-get update"
chroot ${CHROOTDIR} /bin/bash -c "apt-get -y install oem-config oem-config-gtk oem-config-debconf"
chroot ${CHROOTDIR} /bin/bash -c "apt-get -y remove oem-config oem-config-gtk oem-config-debconf"

#replace preseed and linuxconf
mv ${CDOSDIR}/isolinux/isolinux.cfg ${DEBDIR}/
mv ${CDOSDIR}/preseed/cdos.seed ${DEBDIR}/

#replace user-setup-apply
mv ${CHROOTDIR}/usr/lib/ubiquity/user-setup/user-setup-apply ${DEBDIR}/
cp ${CURDIR}/user-setup-apply ${CHROOTDIR}/usr/lib/ubiquity/user-setup/

cfgstr="
default vesamenu.c32
timeout 1

menu background splash.jpg
menu title Welcome to $OSFULLNAME "$OSVERSION" 32-bit

menu color screen	37;40      #80ffffff #00000000 std
MENU COLOR border       30;44   #40ffffff #a0000000 std
MENU COLOR title        1;36;44 #ffffffff #a0000000 std
MENU COLOR sel          7;37;40 #e0ffffff #20ffffff all
MENU COLOR unsel        37;44   #50ffffff #a0000000 std
MENU COLOR help         37;40   #c0ffffff #a0000000 std
MENU COLOR timeout_msg  37;40   #80ffffff #00000000 std
MENU COLOR timeout      1;37;40 #c0ffffff #00000000 std
MENU COLOR msg07        37;40   #90ffffff #a0000000 std
MENU COLOR tabmsg       31;40   #ffDEDEDE #00000000 std
MENU HIDDEN
MENU HIDDENROW 8
MENU WIDTH 78
MENU MARGIN 15
MENU ROWS 5
MENU VSHIFT 7
MENU TABMSGROW 11
MENU CMDLINEROW 11
MENU HELPMSGROW 16
MENU HELPMSGENDROW 29

label live
  menu label Start $OSFULLNAME
  kernel /casper/vmlinuz
  append  file=/cdrom/preseed/$OSNAME.seed boot=casper automatic-ubiquity initrd=/casper/initrd.lz quiet splash --
menu default
label xforcevesa
  menu label Start in compatibility mode
  kernel /casper/vmlinuz
  append  file=/cdrom/preseed/$OSNAME.seed boot=casper xforcevesa nomodeset b43.blacklist=yes initrd=/casper/initrd.lz ramdisk_size=1048576 root=/dev/ram rw noapic noapci nosplash irqpoll --
label check
  menu label Integrity check
  kernel /casper/vmlinuz
  append  boot=casper integrity-check initrd=/casper/initrd.lz quiet splash --
label memtest
  menu label Memory test
  kernel memtest
label local
  menu label Boot from local drive
  localboot 0x80 
"
seed="# Enable extras.ubuntu.com.
#d-i	apt-setup/extras	boolean true
# Install the Ubuntu desktop.
#tasksel	tasksel/first	multiselect 
# On live DVDs, don't spend huge amounts of time removing substantial
# application packages pulled in by language packs. Given that we clearly
# have the space to include them on the DVD, they're useful and we might as
# well keep them installed.
#ubiquity	ubiquity/keep-installed	string icedtea6-plugin openoffice.org

#No language support packages.
#d-i pkgsel/language-pack-patterns string
#d-i pkgsel/install-language-support boolean false

# Auto installation
#d-i auto-install/enable boolean true

# Locale sets language and country.
d-i debian-installer/locale string en_US

# Keyboard selection.
d-i console-setup/layoutcode string us
d-i keyboard-configuration/layoutcode string us  
d-i console-keymaps-at/keymap select us
d-i console-setup/ask_detect boolean false

# Clock and time zone setup
d-i clock-setup/utc boolean false
d-i time/zone string Asia/Shanghai

# PARTION分区部分，默认将根目录挂载到整个磁盘
d-i partman-auto/disk string /dev/sda
d-i partman-auto/method string regular
d-i partman-auto/choose_recipe \ 
         select All files in one partition
d-i partman/confirm_write_new_label boolean true
d-i partman/choose_partition \
         select Finish partitioning and write changes to disk
d-i partman/confirm boolean true

# Account setup
d-i passwd/user-fullname string oem
d-i passwd/username string oem
# Normal user's password, either in clear text
d-i passwd/user-password password cdosoem
d-i passwd/user-password-again password cdosoem

#FINISH FIRST初次完成安装，提示重启
#d-i finish-install/reboot_in_progress note
#d-i debian-installer/exit/halt boolean true
d-i debian-installer/exit/poweroff boolean true"

echo "$cfgstr" > ${CDOSDIR}/isolinux/isolinux.cfg
echo "$seed" > ${CDOSDIR}/preseed/$OSNAME.seed

#********************start************************
sudo umount $CHROOTDIR/proc
sudo umount $CHROOTDIR/dev
#********************end**************************

echo "OEM prepare successful!"


