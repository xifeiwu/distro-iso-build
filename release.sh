#~/bin/sh

WORKPATH=$(cd "$(dirname $0)"; pwd)

sudo sh $WORKPATH/uniso.sh /home/j/Backup/linuxmint-15-cinnamon-dvd-32bit.iso
sudo sh $WORKPATH/release/installzh_CN.sh
sudo sh $WORKPATH/release/installwps.sh
sudo sh $WORKPATH/release/installchrome.sh
sudo sh $WORKPATH/change_welcome_slide.sh
sudo sh $WORKPATH/change_isolinux_splash.sh
sudo sh $WORKPATH/mkiso.sh
