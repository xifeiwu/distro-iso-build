#!/bin/sh

set -e
if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$(cd $1; pwd)
DISTURBPATH=$(cd "$(dirname $0)"; pwd)

echo patching os settings locale zh_CN
msgfmt $DISTURBPATH/zh_CN_po/language-selector.po -o $OUTPATH/squashfs-root/usr/share/locale/zh_CN/LC_MESSAGES/language-selector.mo
echo finished.
