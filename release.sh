#~/bin/sh
set -e

CURPATH=$PWD
WORKPATH=$(cd "$(dirname $0)"; pwd)
ISOPATH=/home/j/Backup/linuxmint-15-cinnamon-dvd-32bit.iso
APPPATH=$CURPATH/app
OUTPATH=$CURPATH/mkiso_out
DEBPATH=/home/rtty/materials

sudo sh $WORKPATH/uniso.sh $ISOPATH
sudo sh $WORKPATH/release/installzh_CN.sh $OUTPATH $APPPATH
sudo sh $WORKPATH/release/installwps.sh $OUTPATH $APPPATH
sudo sh $WORKPATH/release/installchrome.sh $OUTPATH $APPPATH
sudo sh $WORKPATH/release/installvim.sh $OUTPATH $APPPATH
sudo sh $WORKPATH/release/change_welcome_slide.sh $OUTPATH
sudo sh $WORKPATH/release/change_help_slide.sh $OUTPATH
sudo sh $WORKPATH/release/change_isolinux_splash.sh $OUTPATH
sudo sh $WORKPATH/release/info_patch.sh $OUTPATH
sudo sh $WORKPATH/release/application_patch.sh $OUTPATH
sudo sh $WORKPATH/release/mktheme.sh 
sudo sh $WORKPATH/release/custom.sh $DEBPATH
sudo sh $WORKPATH/mkiso.sh
