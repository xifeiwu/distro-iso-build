#~/bin/sh

WORKPATH=$(cd "$(dirname $0)"; pwd)
ISOPATH=/home/rtty/linuxmint-15-cinnamon-dvd-32bit.iso
THEMEPATH=/home/rtty/Void/
DEBPATH=/home/rtty/materials

sudo sh $WORKPATH/uniso.sh $ISOPATH
sudo sh $WORKPATH/mktheme.sh $THEMEPATH
sudo sh $WORKPATH/custom.sh $DEBPATH
sudo sh $WORKPATH/mkiso.sh
