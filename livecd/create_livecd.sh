#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1
LIVECDPATH=$(cd "$(dirname $0)"; pwd)
. $LIVECDPATH/../set_version.sh
isodir=$OSNAME
if [ ! $OSVERSION ] ; then
    echo Error: no OSVERSION env set.
    exit -1
fi
if [ ! $OSVERSIONFULLNAME ] ; then
    echo Error: no OSVERSIONFULLNAME env set.
    exit -1
fi

if [ ! -d $OUTPATH/$isodir/casper ] ; then
    mkdir -p $OUTPATH/$isodir/casper
    #echo error: there is no $isodir path
    #exit -1
fi

if [ ! -z $OUTPATH/$isodir/isolinux ] ; then
    rm -rf $OUTPATH/$isodir/isolinux
fi
mkdir $OUTPATH/$isodir/isolinux
if [ ! -z $OUTPATH/$isodir/preseed ] ; then
    rm -rf $OUTPATH/$isodir/preseed
fi
mkdir $OUTPATH/$isodir/preseed
if [ ! -z $OUTPATH/$isodir/.disk ] ; then
    rm -rf $OUTPATH/$isodir/.disk
fi
mkdir $OUTPATH/$isodir/.disk

cp $LIVECDPATH/files/isolinux/isolinux.bin $OUTPATH/$isodir/isolinux
cp $LIVECDPATH/files/isolinux/memtest86+-5.01.bin $OUTPATH/$isodir/isolinux/memtest
cp $LIVECDPATH/files/isolinux/vesamenu.c32 $OUTPATH/$isodir/isolinux
cp $LIVECDPATH/files/isolinux/splash.png $OUTPATH/$isodir/isolinux
cfgstr="
default vesamenu.c32
timeout 100

menu background splash.png
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
  append  file=/cdrom/preseed/$OSNAME.seed boot=casper initrd=/casper/initrd.lz quiet splash --
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
echo "$cfgstr" > $OUTPATH/$isodir/isolinux/isolinux.cfg

seed="# Enable extras.ubuntu.com.
#d-i	apt-setup/extras	boolean true
# Install the Ubuntu desktop.
#tasksel	tasksel/first	multiselect ubuntu-desktop
# On live DVDs, don't spend huge amounts of time removing substantial
# application packages pulled in by language packs. Given that we clearly
# have the space to include them on the DVD, they're useful and we might as
# well keep them installed.
#ubiquity	ubiquity/keep-installed	string icedtea6-plugin openoffice.org"
echo "$seed" > $OUTPATH/$isodir/preseed/$OSNAME.seed

echo full_cd/single > $OUTPATH/$isodir/.disk/cd_type
echo $OSFULLNAME $OSVERSION "$OSVERSIONFULLNAME" - Release i386 \(`date +%Y%m%d`\) > $OUTPATH/$isodir/.disk/info
echo $OSFULLNAME $OSVERSION "$OSVERSIONFULLNAME" - Release i386 \(`date +%Y%m%d`\) > $OUTPATH/$isodir/.disk/mint4win
touch $OUTPATH/$isodir/.disk/release_notes_url
echo 423b762a-38e0-4f2d-8632-459f826c6699 > $OUTPATH/$isodir/.disk/casper-uuid-generic
echo 423b762a-38e0-4f2d-8632-459f826c6699 > $OUTPATH/$isodir/.disk/live-uuid-generic
