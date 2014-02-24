#!/bin/sh
#set -e

if [ $# -eq 1 ] ; then
    CHROOTDIR=$1
else
    echo You should execute this script with one param at least as follow:
    echo sh $0 CHROOTDIR 
    exit -1
fi

COSDISTURBREPOIP=124.16.141.172
COSREPOIP=124.16.141.149
echo "deb http://${COSDISTURBREPOIP}/cos iceblue main universe" > /tmp/cos-repository.list
sudo mv /tmp/cos-repository.list $CHROOTDIR/etc/apt/sources.list.d/
sudo chroot $CHROOTDIR /bin/bash -c "wget -q -O - http://${COSDISTURBREPOIP}/cos/project/keyring.gpg | apt-key add -"
sudo chroot $CHROOTDIR /bin/bash -c "wget -q -O - http://${COSDISTURBREPOIP}/cos/project/coskeyring.gpg | apt-key add -"

codename=`sed -n '2p' /etc/apt/preferences | awk '{print $3}'`
if [ "${codename}" != "n=iceblue" ] ; then
    sed -i '1i\Package: *\
Pin: release n=iceblue\
Pin-Priority: 750\

    ' ${CHROOTDIR}/etc/apt/preferences
fi

echo "deb http://${COSREPOIP}/repos/cos cos main
deb http://${COSREPOIP}/repos/mint olivia main upstream import
deb http://${COSREPOIP}/repos/ubuntu raring main restricted universe multiverse
deb http://${COSREPOIP}/repos/ubuntu raring-security main restricted universe multiverse
deb http://${COSREPOIP}/repos/ubuntu raring-updates main restricted universe multiverse
deb http://${COSREPOIP}/repos/ubuntu raring-proposed main restricted universe multiverse
deb http://${COSREPOIP}/repos/ubuntu raring-backports main restricted universe multiverse
deb http://${COSREPOIP}/repos/security-ubuntu/ubuntu raring-security main restricted universe multiverse
deb http://${COSREPOIP}/repos/canonical/ubuntu raring partner" >/tmp/official-package-repositories.list
sudo mv /tmp/official-package-repositories.list $CHROOTDIR/etc/apt/sources.list.d/
sudo chroot $CHROOTDIR /bin/bash -c "wget -q -O - http://${COSREPOIP}/repos/cos.gpg.key | apt-key add -"
echo Finished generating cos source list.
