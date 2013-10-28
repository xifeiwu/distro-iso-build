#~/bin/sh
set -e

if [ $# -lt 3 ] ; then
    echo You should execute this script with three param at least as follow:
    echo sh $0 ISOPATH APPPATH OUTPATH
    exit -1
fi

if [ ! -f $1 ] ; then
    echo You should make sure the iso $1 is a file that exists
    exit -1
fi

if [ ! -d $2 ] ; then
    echo You should make sure the apppath $2 is a dir that exists
    exit -1
fi

if [ -e $3 ] ; then
    if [ ! -d $3 ] ; then
        echo You should make sure the outpath $3 is a dir
        exit -1
    fi
else
    mkdir $3
fi

ScriptPATH=$(cd "$(dirname $0)"; pwd)
ISOPATH=$1
APPPATH=$(cd $2; pwd)
OUTPATH=$(cd $3; pwd)

if [ $# -ge 4 ] && [ ! -f $4 ]  ; then
    if [ ! -e $4 ] ; then
       mkdir $4
    fi
    GENISOPATH=$(cd $4; pwd)
else
    GENISOPATH=$OUTPATH
fi

echo The iso will be generated in $GENISOPATH

echo ISOPATH=$ISOPATH
echo APPPATH=$APPPATH
echo OUTPATH=$OUTPATH

######
#Unzip iso
######
sudo sh $ScriptPATH/uniso.sh $ISOPATH $OUTPATH

#Install cos boot splash
#sudo sh $ScriptPATH/release/installcossplash.sh $OUTPATH $APPPATH

#Build and install cinnamon and cinnamon-common
sudo sh $ScriptPATH/release/install_deb_cinnamon.sh $OUTPATH

#Install zh_CN deb and Input Method deb.
sudo sh $ScriptPATH/release/installzh_CN.sh $OUTPATH $APPPATH

#Install popular software
sudo sh $ScriptPATH/release/installwps.sh $OUTPATH $APPPATH
sudo sh $ScriptPATH/release/installchrome.sh $OUTPATH $APPPATH
sudo sh $ScriptPATH/release/installvim.sh $OUTPATH $APPPATH
sudo sh $ScriptPATH/release/installwineqq.sh $OUTPATH $APPPATH

#Install ssh and close root user with ssh authority.
sudo sh $ScriptPATH/release/installssh.sh $OUTPATH $APPPATH

#Install Self software
sudo sh $ScriptPATH/release/installrdpdesk.sh $OUTPATH $APPPATH
sudo sh $ScriptPATH/release/installqtadb.sh $OUTPATH $APPPATH

#Change start and install step
sudo sh $ScriptPATH/release/change_isolinux_splash.sh $OUTPATH
sudo sh $ScriptPATH/release/patch_info.sh $OUTPATH
sudo sh $ScriptPATH/release/patch_slides.sh $OUTPATH

#Change some zh_CN LC_MESSAGES
sudo sh $ScriptPATH/release/change_zh_CN.sh $OUTPATH

#Change system name in some where. This shell file also will install some software in cos source list.
#sudo sh $ScriptPATH/release/custom.sh $OUTPATH
sudo sh $ScriptPATH/release/ubiquity.sh $ScriptPATH/release/ $OUTPATH
sudo sh $ScriptPATH/release/packages.sh $ScriptPATH/release/ $OUTPATH

#Change some icon\theme\applications name and so on.
sudo sh $ScriptPATH/release/mktheme.sh $OUTPATH
sudo sh $ScriptPATH/release/change_start_menu.sh $OUTPATH
sudo sh $ScriptPATH/release/change_icons.sh $OUTPATH
sudo sh $ScriptPATH/release/reconfig_start_menu.sh $OUTPATH

#fix a bug of wps when first opened.
sudo sh $ScriptPATH/release/set_username_for_WPS.sh $OUTPATH

#Remove wubi
sudo sh $ScriptPATH/release/change_wubi.sh $OUTPATH

######
#Make iso.
######
sudo sh $ScriptPATH/mkiso.sh $OUTPATH $GENISOPATH
