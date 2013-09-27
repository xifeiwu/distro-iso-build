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

sudo sh $ScriptPATH/uniso.sh $ISOPATH $OUTPATH
sudo sh $ScriptPATH/release/installzh_CN.sh $OUTPATH $APPPATH
sudo sh $ScriptPATH/release/installopenoffice.sh $OUTPATH $APPPATH
sudo sh $ScriptPATH/release/installwps.sh $OUTPATH $APPPATH
sudo sh $ScriptPATH/release/installchrome.sh $OUTPATH $APPPATH
sudo sh $ScriptPATH/release/installvim.sh $OUTPATH $APPPATH
sudo sh $ScriptPATH/release/installwineqq.sh $OUTPATH $APPPATH
sudo sh $ScriptPATH/release/installssh.sh $OUTPATH $APPPATH
sudo sh $ScriptPATH/release/change_welcome_slide.sh $OUTPATH
sudo sh $ScriptPATH/release/change_help_slide.sh $OUTPATH
sudo sh $ScriptPATH/release/change_isolinux_splash.sh $OUTPATH
sudo sh $ScriptPATH/release/patch_schemas.sh $OUTPATH
sudo sh $ScriptPATH/release/patch_info.sh $OUTPATH
sudo sh $ScriptPATH/release/patch_applications.sh $OUTPATH
sudo sh $ScriptPATH/release/mktheme.sh $OUTPATH
sudo sh $ScriptPATH/release/custom.sh $OUTPATH
sudo sh $ScriptPATH/release/set_username_for_WPS.sh $OUTPATH
sudo sh $ScriptPATH/release/delete_display_in_preferences.sh $OUTPATH
sudo sh $ScriptPATH/release/change_start_menu.sh $OUTPATH
sudo sh $ScriptPATH/release/change_icons.sh $OUTPATH
sudo sh $ScriptPATH/release/change_wubi.sh $OUTPATH
sudo sh $ScriptPATH/release/reconfig_start_menu.sh $OUTPATH
sudo sh $ScriptPATH/mkiso.sh $OUTPATH $GENISOPATH
