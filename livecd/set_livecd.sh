#!/bin/sh
set -e

if [ -z "$1" ] ; then
    echo error: No outpath setting at first param.
    exit -1
fi

OUTPATH=$1
LIVECDPATH=$(cd "$(dirname $0)"; pwd)
if [ ! -x $OUTPATH/mycos ] ; then
    echo error: there is no mycos path
    exit -1
fi
cp -r $LIVECDPATH/files/. $OUTPATH/mycos/
