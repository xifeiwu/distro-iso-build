#!/bin/sh
#set -e

if [ $# -eq 2 ] ; then
    MATERIALDIR=$1
    WORKDIR=$2
else
    echo You should execute this script with three param at least as follow:
    echo sh $0 MATERIALDIR WORKDIR
    exit -1
fi

cd ${WORKDIR}
chroot squashfs-root /bin/bash -c "[ -e /proc/mounts ] && umount /proc/"
chroot squashfs-root /bin/bash -c "mount none /proc -t proc"

chroot squashfs-root /bin/bash -c "bash /tmp/deb-replace.sh"
chroot squashfs-root /bin/bash -c "umount /proc/"

