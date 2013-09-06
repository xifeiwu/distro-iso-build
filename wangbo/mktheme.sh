#!/bin/sh
OUTPATH=$PWD/mkiso_out
echo warning:you should run as root. But be careful!
echo Note:linux_mint_15.png in wall paper path is the default background!

if [ "$USER" != "root" ] ; then
    echo "error: you are not run as root user, you should excute su ."
    exit
fi

if [ -z "$1" ] ; then
    echo "error: you should input cinnamon theme path as first parameter. 
    echo Just as: sh mkiso.sh theme paperpath"
    exit
fi

if [ -z "$2" ] ; then
    echo "error: you should input wall paper path as second parameter." 
    echo "Just as: sh mkiso.sh theme paperpath"
    exit
fi

THEMEPATH=$1

WALLPAPER=$2

if [ ! -d $THEMEPATH ] ; then
    echo error: theme path is not exist, you should set it correctly. Wrong PATH:$THEMEPATH
    exit
fi

if [ ! -d $WALLPAPER ] ; then
    echo error: wall paper path is not exist, you should set it correctly. Wrong PATH:$WALLPAPER
    exit
fi

if [ ! -d $OUTPATH ] ; then
    echo error: outpath does not exist, you should run uniso.sh first
    exit
fi

PICPATH=$OUTPATH/squashfs-root/usr/share/backgrounds/linuxmint-olivia/

rm -f $PICPATH/*.png
rm -f $PICPATH/*.jpg

cp $WALLPAPER/*.png $PICPATH
cp $WALLPAPER/*.jpg $PICPATH

DEFTHEMEPATH1=$OUTPATH/squashfs-root/usr/share/themes
mv -f $DEFTHEMEPATH1/Linux\ Mint/ $DEFTHEMEPATH1/Linux\ iscas/
rm -f $DEFTHEMEPATH1/Linux\ iscas/cinnamon/*.svg
rm -f $DEFTHEMEPATH1/Linux\ iscas/cinnamon/*.png
rm -f $DEFTHEMEPATH1/Linux\ iscas/cinnamon/*.css

cp $THEMEPATH/cinnamon/* $DEFTHEMEPATH1/Linux\ iscas/cinnamon/
chmod 644 $DEFTHEMEPATH1/Linux\ iscas/cinnamon/*

DEFTHEMEPATH2=$OUTPATH/squashfs-root/usr/share/cinnamon/theme
rm -f $DEFTHEMEPATH2/*.svg
rm -f $DEFTHEMEPATH2/*.png
rm -f $DEFTHEMEPATH2/*.css
cp $THEMEPATH/cinnamon/* $DEFTHEMEPATH2/
chmod 644 $DEFTHEMEPATH2/*

echo Done! 


