#!/bin/sh
set -e

if [ "$USER" != "root" ] ; then
    echo "error: you are not run as root user, you should excute sudo."
    exit
fi
if [ $# -eq 0 ] ; then
    BASEPATH="/home/xifei/Public"
    MATERIALDIR="${BASEPATH}/coscustom"
    WORKDIR="${BASEPATH}/OS-Custom"
elif [ $# -eq 2 ] ; then
    MATERIALDIR=$1
    WORKDIR=$2
else
    echo You should execute this script with three param at least as follow:
    echo sh $0 MATERIALDIR WORKDIR
    exit -1
fi

#misc_py="squashfs-root/usr/lib/ubiquity/ubiquity/misc.py"
#cp -r ${MATERIALDIR}/${misc_py} ${WORKDIR}/${misc_py}

#templates_dat="squashfs-root/var/cache/debconf/templates.dat"
#cp -r ${MATERIALDIR}/${templates_dat} ${WORKDIR}/${templates_dat}

#languagelist_data_gz="squashfs-root/usr/lib/ubiquity/localechooser/languagelist.data.gz"
#cp -r ${MATERIALDIR}/${languagelist_data_gz} ${WORKDIR}/${languagelist_data_gz}
#i18n_py="squashfs-root/usr/lib/ubiquity/ubiquity/i18n.py"
#cp -r ${MATERIALDIR}/${i18n_py} ${WORKDIR}/${i18n_py}

#ubiquity_slideshow_dir="squashfs-root/usr/share/ubiquity-slideshow"
#cp -r ${MATERIALDIR}/${ubiquity_slideshow_dir}/* ${WORKDIR}/${ubiquity_slideshow_dir}/
function run_patch(){
    set +e
    patch --dry-run -N $*
    ERROR=$?
    set -e
    if [ $ERROR -eq 0 ] ; then
        patch -N $*
    else
        patch -R -N $*
        patch -N $*
    fi
}

echo -e "\033[31m - custom ubiquity. \033[0m"
cd ${MATERIALDIR}/ubiquity
set +e
diff -urNa squashfs-root-raw squashfs-root > /tmp/ubiquity.patch
set -e
run_patch -p0 -d ${WORKDIR}/ -i /tmp/ubiquity.patch
rm /tmp/ubiquity.patch
echo -e "\033[31m - custom ubiquity finished. \033[0m"
