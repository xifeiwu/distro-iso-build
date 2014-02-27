#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1
echo warning:you should run as root. But be careful!

DISTURBPATH=$(cd "$(dirname $0)"; pwd)

if [ "$USER" != "root" ] ; then
    echo "error: you are not run as root user, you should excute su ."
    exit
fi





THEMEPATH=$DISTURBPATH/Facebook


if [ ! -d $THEMEPATH ] ; then
    echo error: theme path is not exist, you should set it correctly. Wrong PATH:$THEMEPATH
    exit
fi


if [ ! -d $OUTPATH ] ; then
    echo error: outpath does not exist, you should run uniso.sh first
    exit
fi


DEFTHEMEPATH1=$OUTPATH/squashfs-root/usr/share/themes
if [ -d $DEFTHEMEPATH1/Linux\ Mint/ ] ; then
    mv -f $DEFTHEMEPATH1/Linux\ Mint/ $DEFTHEMEPATH1/Linux\ iscas/
fi
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


