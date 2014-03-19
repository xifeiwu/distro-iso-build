function hh() {
cat <<EOF
Invoke ". build/envsetup.sh" from your shell to add the following functions to your environment:
- croot:     Changes directory to the top of the tree.
- cmaster:   repo forall -c git checkout -b master remotes/m/master
- check:     Check the tools and dependencies to should be installed.
- getprepkg: Get raw iso and some deb packages such as wps.
- cclean:    Clean the workout dir excepte raw mint.iso and $PREAPP dir.
- m:         Build the package and clean the source dir in the current directory.
- mm:        Build the package and not clean the source dir in the current directory.
- mi:        Build and install the package and clean the source dir in the current directory.
- mos:       Build all and generate iso.
- mall:      Build all packages in $OSNAME and desktop dir, and then move these .deb .tar.gz .dsc .changes file to workout/app dir.
- uniso:     Export iso file to workout/out dir.
- mkiso:     Generate iso file into workout dir from workout/out file.
- runiso:    Run iso by kvm command.
- flashiso:  Flash iso by usb-creator-gtk command.
- cgrep:     Greps on all local C/C++ files.
- psgrep:    Greps on all local py js files.
- jgrep:     Greps on all local Java files.
- godir:     Go to the directory containing a file.
- hos:       show more help.

Look at the source to view more functions. The complete list is:
EOF
    T=$(gettop)
    local A
    A=""
    for i in `cat $T/build/envsetup.sh | sed -n "/^function /s/function \([a-z_]*\).*/\1/p" | sort`; do
      A="$A $i"
    done
    echo $A
}

function hos()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi

    cat $T/docs/repo_help.txt | more
}

function repo()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    
    $T/.repo/repo/repo $*

    if [ $# -eq 1 ] ; then
        if [ "$1" == "sync" ] ; then
            source $T/build/envsetup.sh
        fi
    fi
}

function resource()
{
    source $T/build/envsetup.sh
}

function setenv()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi

    . $T/build/set_version.sh
    . $T/build/core/install_kernel.sh
    . $T/build/core/vendor/install_nvidia_lenovo.sh

    export OSARCH=i386
    export BASE_RELEASE=raring
    export BASE_RELEASE_WEB=http://192.168.160.169/cos3/ubuntu/

    export OUT=$T/workout
    export ROOTFS=$OUT/out/squashfs-root
    export APPOUT=debsaved
    export PREAPP=preapp
    export BUILDOSDIRS="$OSNAME mint desktop"
    export REPODIRNAME=repository
    export REPOSITORY=$OUT/$REPODIRNAME
    export BUILDOSSTEP=$OUT/out/buildosstep
    export RAWSQUASHFSNAME=filesystem-linuxmint-15-cinnamon-32bit.squashfs
    export RAWSQUASHFSNAME_SRC=filesystem-zhoupeng-20140108.squashfs
    export ISOPATH=$OUT/$RAWSQUASHFSNAME
    export RAWSQUASHFSADDRESS=box@192.168.162.142:/home/box/Workspace/Public/$RAWSQUASHFSNAME
    export RAWPREAPPADDRESS=box@192.168.162.142:/home/box/Workspace/Public/app/
    export KERNEL_VERSION=3.8.13
    export KERNEL_VERSION_FULL=3.8.13.13-cdos
}

function addcompletions()
{
    local T dir f

    # Keep us from trying to run in something that isn't bash.
    if [ -z "${BASH_VERSION}" ]; then
        return 1
    fi

    # Keep us from trying to run in bash that's too old.
    if [ ${BASH_VERSINFO[0]} -lt 3 ]; then
        return 1
    fi

    dir="sdk/bash_completion"
    if [ -d ${dir} ]; then
        for f in `/bin/ls ${dir}/[a-z]*.bash 2> /dev/null`; do
            echo "including $f"
            . $f
        done
    fi
}

function gettop
{
    local TOPFILE=build/envsetup.sh
    if [ -n "$TOP" -a -f "$TOP/$TOPFILE" ] ; then
        echo $TOP
    else
        if [ -f $TOPFILE ] ; then
            # The following circumlocution (repeated below as well) ensures
            # that we record the true directory name and not one that is
            # faked up with symlink names.
            PWD= /bin/pwd
        else
            # We redirect cd to /dev/null in case it's aliased to
            # a command that prints something as a side-effect
            # (like pushd)
            local HERE=$PWD
            T=
            while [ \( ! \( -f $TOPFILE \) \) -a \( $PWD != "/" \) ]; do
                cd .. > /dev/null
                T=`PWD= /bin/pwd`
            done
            cd $HERE > /dev/null
            if [ -f "$T/$TOPFILE" ]; then
                echo $T
            fi
        fi
    fi
}

function croot()
{
    T=$(gettop)
    if [ "$T" ]; then
        cd $(gettop)
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function cmaster()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    
    repo forall -c git checkout -b master remotes/m/master
    repo forall -c git config push.default upstream
}

function checktools()
{
    command -v unsquashfs > /dev/null
    if [ ! $? == 0 ] ; then
        echo ERROR: squashfs-tools has not been installed.
        command -v reprepro > /dev/null
        if [ ! $? == 0 ] ; then
            echo ERROR: reprepro has not been installed.
        fi
        return 1
    fi
    command -v reprepro > /dev/null
    if [ ! $? == 0 ] ; then
        echo ERROR: reprepro has not been installed.
        return 1
    fi
    return 0
}

function check()
{
    checktools || return 1
    checkdepall || return 1
}

function checkdep()
{
    tmpstr=`dpkg-checkbuilddeps 2>&1`
    tmpres=$?
    echo $tmpstr | awk '{gsub(/\([^\(\)]*\)/, ""); print}'
    return $tmpres
}

function checkdepall()
{
    T=$(gettop)
    if [ "$T" ]; then
        CURDIR=$PWD
        echo check build dependencies and conflicts of all deb package
        echo
        for maindir in $BUILDOSDIRS
        do
            for dir in `ls $T/$maindir | sort`
            do
                if [ -d $T/$maindir/$dir ] ; then
                    cd $T/$maindir/$dir
                    echo checking dependencies of $dir
                    tmpstr=`dpkg-checkbuilddeps 2>&1`
                    tmpres=$?
                    echo $tmpstr | awk '{gsub(/\([^\(\)]*\)/, ""); print}'
                fi
            done 
        done
        echo
        echo Finish checking building deb packages
        cd $CURDIR
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function uniso()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    if [ ! -e $OUT/out ] ; then
        mkdir -p $OUT/out
    fi
    checktools || return 1
    sudo sh $T/build/uniso.sh $ISOPATH $OUT/out || return 1
    sudo sh $T/build/livecd/create_livecd.sh $OUT/out || return 1
}

function mkiso()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    umountdir
    if [ $# -gt 0 ] ; then
        sudo sh $T/build/mkiso.sh $OUT/out $OUT $1 || return 1
    else
        sudo sh $T/build/mkiso.sh $OUT/out $OUT || return 1
    fi
}

function mkiso_debug()
{
    if [ $# -lt 3 ] ; then
        echo You should execute this cmd with three param at least as follow:
        echo "mkiso_debug xxx.iso OUTPATH APPPATH"
        return 1
    fi

    if [ ! -d $2 ] ; then
        echo You should make sure the OUTPATH $1 is a dir
        return 1
    fi

    if [ ! -d $3 ] ; then
        echo You should make sure the APPPATH $2 is a dir
        return 1
    fi

    T=$(gettop)
    if [ ! "$T" ]; then
        echo "fail to locate the top of the tree.  Try setting TOP."
        return 1
    fi

    sudo sh $T/build/debug/installkdump.sh $2 $3 || return 1
    mkiso $1 || return 1
    sudo sh $T/build/debug/uninstallkdump.sh $2 $3 || return 1
}

function mkiso_oem()
{
    if [ $# -lt 3 ] ; then
        echo You should execute this cmd with three param at least as follow:
        echo "mkiso_oem xxx.iso OUTPATH APPPATH"
        return 1
    fi

    if [ ! -d $2 ] ; then
        echo You should make sure the OUTPATH $2 is a dir
        return 1
    fi

    if [ ! -d $3 ] ; then
        echo You should make sure the APPPATH $3 is a dir
        return 1
    fi

    T=$(gettop)
    if [ ! "$T" ]; then
        echo "fail to locate the top of the tree.  Try setting TOP."
        return 1
    fi

    sudo sh $T/build/oem/preoem.sh $2 $3 || return 1
    umountdir
    if [ $# -gt 0 ] ; then
        sudo sh $T/build/oem/mkiso_oem.sh $OUT/out $OUT $1 || return 1
    else
        sudo sh $T/build/oem/mkiso_oem.sh $OUT/out $OUT || return 1
    fi
    sudo sh $T/build/oem/postoem.sh $2 $3 || return 1
}

function m()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    mm -tc $*
}

function mm()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    ISINSTALL=0
    ISLOCAL=0
    while [ $# -gt 0 ]; do
        if [ "$1" == "--install" ] ; then
            shift
            ISINSTALL=1
        elif [ "$1" == "--local" ] ; then
            shift
            ISLOCAL=1
        else
            break
        fi
    done
    if [ "$T" ]; then
        if [ ! -e $OUT ] ; then
            mkdir $OUT
        fi
        checktools || return 1
        if [ ! -f debian/rules ] ; then
            echo ERROR: No file debian/rules founded. Maybe this is not a debian package source dir.
            return 1
        fi
        for file in `ls ../ | sort`
        do
            if [ -f ../$file ] ; then
                echo ERROR: The files in parent dir should be moved into somewhere. Maybe they are the last files generated when last building.
                echo
                echo tips: cmove: you should enter cmove command to clean these files.
                return 1
            fi
        done 
        checkdep
        if [ ! $? == 0 ] ; then
            return 1
        fi
        dpkg-buildpackage -d $*
        echo
        echo The list of deb files generated.
        ls -1 ../*.deb
        echo
        HASDEBFILE=0
        DEBTOINSTALL=""
        for file in `ls ../*.deb | sort`
        do
            if [ -f $file ] ; then
                HASDEBFILE=1
                DEBNAME=`dpkg -f $file Package`
                DEBTOINSTALL=`echo $DEBTOINSTALL $DEBNAME`
                addrepository $file
            fi
        done 
        if [ $HASDEBFILE == 0 ] ; then
            echo ERROR: No deb file generated. Some error happened in dpkg-buildpackage -d $*
            cmove || return 1
            return 1
        else
            dir=$(basename $PWD)
            maindir=$(basename $(dirname $PWD))
            git log -1 | head -n 1 >$OUT/$APPOUT/$maindir/$dir/logid
            cmove --built || return 1
            echo Info: These deb files above has been added into repository.
            if [ $ISINSTALL == 1 ] ; then
                if [ $ISLOCAL == 0 ] ; then
                    installdeb "$DEBTOINSTALL" || return 1
                else
                    installdebtolocal "$DEBTOINSTALL" || return 1
                fi
            fi 
        fi
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function mi()
{
    T=$(gettop)
    if [ "$T" ]; then
        mm --install -tc || return 1
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function mil()
{
    T=$(gettop)
    if [ "$T" ]; then
        mm --install --local -tc || return 1
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function mall()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    if [ "$T" ]; then
        if [ ! -e $REPOSITORY ] ; then
            mkdir -p $REPOSITORY
        fi
        isskipcheck=0
        if [ $# -ge 1 ] ; then
            for i in "$@"
            do
    	    if [[ "$i" == "--skip" ]] ; then
                    isskipcheck=1
                fi
            done 
        fi
        CURDIR=$PWD
        if [ $isskipcheck -eq 0 ] ; then
            echo check build dependencies and conflicts of all deb package
            checkdepall | grep dpkg-checkbuilddeps
            if [ $? -eq 0 ] ; then
                echo Error: some dependencis has not been met.
                return 1
            fi
            echo Finish checking building deb packages
        fi
        echo ===
        echo ===================Building all deb packages=======================
        echo
        for maindir in $BUILDOSDIRS
        do
            for dir in `ls $T/$maindir | sort`
            do
                if [ -d $T/$maindir/$dir ] ; then
                    echo =======Building $maindir/$dir
                    cd $T/$maindir/$dir
                    nowlogid=`git log -1 | head -n 1`
                    lastlogid="##"
                    if [ -f $OUT/$APPOUT/$maindir/$dir/logid ] ; then
                        lastlogid=`cat $OUT/$APPOUT/$maindir/$dir/logid`
                    else
                        mkdir -p $OUT/$APPOUT/$maindir/$dir
                    fi
                    if [ ! "$nowlogid" == "$lastlogid" ] ; then
                        echo Git log from $lastlogid to $nowlogid
                        mm -tc || return 1
                        if [ $? -ne 0 ] ; then
                            echo Error has happened when building $dir. Please check the log above. You can enter checkdepall to find the whole list of dependencies to require.
                            return 1
                        fi
                    else
                        echo No update in $dir, so it do not need to be rebuilt.
                    fi
                fi
            done 
        done
        echo
        echo Finish building all deb packages
        echo  
        cd $CURDIR
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function mroot()
{
#    if [ -d $OUT/out ] ; then
#        echo ERROR:out dir has exist.
#        return 1
#    fi
#    mkdir -p $OUT/out || return 1

    echo Begin to debootstrap...
    sudo debootstrap --arch=${OSARCH} --no-check-gpg ${BASE_RELEASE} $ROOTFS ${BASE_RELEASE_WEB}  || return 1
    echo End debootstraping...
}

function mrootbuilder()
{
    if [ ! -d $OUT/out/squashfs-root ] ; then
        echo ERROR:out/squashfs-root dir has not exist.
        return 1
    fi
    T=$(gettop)
    sudo mount --bind /dev $OUT/out/squashfs-root/dev
    sudo cp /etc/hosts $OUT/out/squashfs-root/etc/hosts
    sudo cp /etc/resolv.conf $OUT/out/squashfs-root/etc/resolv.conf
    sudo cp $T/build/core/srcbuild/official-package-repositories.list $OUT/out/squashfs-root/etc/apt/sources.list
    sudo cp $T/build/core/srcbuild/preferences $OUT/out/squashfs-root/etc/apt/preferences
    sudo cp $T/build/core/srcbuild/99myown $OUT/out/squashfs-root/etc/apt/apt.conf.d/99myown

    #backup /sbin/initctl in squashfs-root
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo cp /sbin/initctl /sbin/initctl.bak"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "mount none -t proc /proc"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "mount none -t sysfs /sys"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "mount none -t devpts /dev/pts"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "export HOME=/root"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "export LC_ALL=C"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y --force-yes update" || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y -f install" || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y --force-yes install dbus" || return 1 # ???
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dbus-uuidgen > /var/lib/dbus/machine-id"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg-divert --local --rename --add /sbin/initctl"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "ln -s /bin/true /sbin/initctl"
    sudo rm -f $T/build/core/srcbuild/fail_stage1
    sudo rm -f $T/build/core/srcbuild/fail_stage2
    sudo rm -f $T/build/core/srcbuild/fail_stage3
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y -f install" || return 1

    # stage1
    echo "------------------------------stage1------------------------------------------"
    while read list
    do
        pkgsname=`echo $list | awk '{print $1}'`
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get install --yes --allow-unauthenticated ${pkgsname}"
        if [ $? -ne 0 ];then
                echo $pkgsname >>  $T/build/core/srcbuild/fail_stage1
        fi
    done < $T/build/core/srcbuild/filesystem.manifest

    # stage1.1 install close source pkgs (Third party packages not in official)
    echo "------------------------------stage1.1------------------------------------------"
    sudo mkdir $OUT/out/squashfs-root/3rdpart
    sudo cp  $T/build/core/srcbuild/3rdpart/*.deb $OUT/out/squashfs-root/3rdpart
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd 3rdpart && dpkg -i *.deb"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm -rf 3rdpart"

    # stage 2
    echo "------------------------------stage2------------------------------------------"
    while read pkgsname
    do
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get install --yes --allow-unauthenticated ${pkgsname}"
        if [ $? -ne 0 ];then
                echo $pkgsname >>  $T/build/core/srcbuild/fail_stage2
        fi
    done <  $T/build/core/srcbuild/fail_stage1

    # stage3 force install
    echo "------------------------------stage3------------------------------------------"
    while read pkgsname
    do
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get install --yes --force-yes --allow-unauthenticated ${pkgsname}"
        if [ $? -ne 0 ];then
                echo $pkgsname >>  $T/build/core/srcbuild/fail_stage3
        fi
    done <  $T/build/core/srcbuild/fail_stage2

    # clean unnecessary packages
    echo "-----------apt-get autoremove, clean unnecessary dependency packages---------"
    # autoremove is used to remove packages that were automatically installed to satisfy dependencies for other packages and are now no longer needed.
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y --force-yes autoremove" || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y --force-yes clean" || return 1

    #clean squashfs
#    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /etc/apt/sources.list"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /etc/apt/preferences"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /etc/apt/apt.conf.d/99myown"

    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /var/lib/dbus/machine-id"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /sbin/initctl"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg-divert --rename --remove /sbin/initctl"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y --force-yes clean"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm -rf /tmp/*"
    echo "nameserver 8.8.8.8">/tmp/resolv.conf
    sudo cp /tmp/resolv.conf $OUT/out/squashfs-root/etc/resolv.conf
    #sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /etc/resolv.conf"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "umount -lf /proc"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "umount -lf /sys"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "umount -lf /dev/pts"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "exit"
    sudo umount -l $OUT/out/squashfs-root/dev
}

#Create link libudev.so.0 -> libudev.so.1
function createlink()
{
    paths=(
        "/lib/x86_64-linux-gnu/libudev.so.1" # Ubuntu, Xubuntu, Mint
        "/usr/lib64/libudev.so.1" # SUSE, Fedora
        "/usr/lib/libudev.so.1" # Arch, Fedora 32bit
        "/lib/i386-linux-gnu/libudev.so.1" # Ubuntu 32bit
    )
    for i in "${paths[@]}"
    do
        if [ -f $i ] ; then
        dirpath=$(dirname $i)
        if [ ! -e $dirpath/libudev.so.0 ] ; then
            sudo ln -sf "$i" $dirpath/libudev.so.0
        fi
        echo "create link succefull "
        break
        fi
    done
}

function _mbos()
{
    ISONLINE=0
    BUITSTEP=0
    IS4LENOVO=0
    IS4S3G=0
    IS4TEST=0
    IS4DEBUG=0
    ISFROMSRC=0
    IS4OEM=0
    if [ -e $BUILDOSSTEP ] ; then
        BUITSTEP=`cat $BUILDOSSTEP`
        if [ "$BUITSTEP" -gt 0 ] 2>/dev/null ; then
            BUITSTEP=$BUITSTEP
        else
            BUITSTEP=0
        fi
    fi
    for i in "$@"
    do
        if [ "$i" == "--online" ] ; then
            ISONLINE=1
        elif [ "$i" == "--lenovo" ] ; then
            IS4LENOVO=1
        elif [ "$i" == "--s3g" ] ; then
            IS4S3G=1
	elif [ "$i" == "--test" ] ; then
	    IS4TEST=1
	elif [ "$i" == "--debug" ] ; then
	    IS4DEBUG=1
	elif [ "$i" == "--srcbuild" ] ; then
	    ISFROMSRC=1
	elif [ "$i" == "--oem" ] ; then
	    IS4OEM=1
        else
            if [ "$i" -gt 0 ] 2>/dev/null ; then
                BUITSTEP=$i
            elif [ "$i" == 0 ] ; then
                BUITSTEP=$i
            fi
        fi
    done

    T=$(gettop)
    if [ "$T" ]; then
        #Install zh_CN deb and Input Method deb.
        OUTPATH=$OUT/out
        APPPATH=$OUT/$PREAPP

        if [ ! -e $OUT/out ] ; then
            mkdir -p $OUT/out
        else
            touch $BUILDOSSTEP 2>/dev/null
            if [ $? -ne 0 ] ; then
                Group=`groups $USER | cut -d ' ' -f 1`
                sudo chown $Group.$USER $OUT/out
            fi
        fi

        echo Building $OSFULLNAME...
        if [ $BUITSTEP -le 10 ] ; then
            echo 10 >$BUILDOSSTEP
            getprepkg || return 1
        fi
        if [ $BUITSTEP -le 20 ] ; then
            echo 20 >$BUILDOSSTEP
            checktools || return 1
            createlink || return 1
            mall || return 1
        fi
        if [ $BUITSTEP -le 30 ] ; then
            echo 30 >$BUILDOSSTEP
	    if [ $ISFROMSRC -eq 1 ] ; then
	        mroot || return 1
		mrootbuilder || return 1
                sudo sh $T/build/livecd/create_livecd.sh $OUT/out || return 1
	    else
                uniso || return 1
	   fi
        fi
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function _mcos()
{
    ISONLINE=0
    BUITSTEP=0
    IS4LENOVO=0
    IS4S3G=0
    IS4TEST=0
    IS4DEBUG=0
    ISFROMSRC=0
    IS4OEM=0
    if [ -e $BUILDOSSTEP ] ; then
        BUITSTEP=`cat $BUILDOSSTEP`
        if [ "$BUITSTEP" -gt 0 ] 2>/dev/null ; then
            BUITSTEP=$BUITSTEP
        else
            BUITSTEP=0
        fi
    fi
    echo "BUITSTEP = $BUITSTEP"
    for i in "$@"
    do
        if [ "$i" == "--online" ] ; then
            ISONLINE=1
        elif [ "$i" == "--lenovo" ] ; then
            IS4LENOVO=1
        elif [ "$i" == "--s3g" ] ; then
            IS4S3G=1
	elif [ "$i" == "--test" ] ; then
	    IS4TEST=1
	elif [ "$i" == "--debug" ] ; then
	    IS4DEBUG=1
	elif [ "$i" == "--srcbuild" ] ; then
	    ISFROMSRC=1
	elif [ "$i" == "--oem" ] ; then
	    IS4OEM=1
        else
            if [ "$i" -gt 0 ] 2>/dev/null ; then
                BUITSTEP=$i
            elif [ "$i" == 0 ] ; then
                BUITSTEP=$i
            fi
        fi
    done

    T=$(gettop)
    if [ "$T" ]; then
        #Install zh_CN deb and Input Method deb.
        OUTPATH=$OUT/out
        APPPATH=$OUT/$PREAPP

	if [ $BUITSTEP -le 31 ] ; then
            echo 31 >$BUILDOSSTEP
            if [ -e $OUT/tmpdir ] ; then
                sudo rm -rf $OUT/tmpdir/*
                echo "rm tmpdir!"
            else
                mkdir -p $OUT/tmpdir
                echo "mkdir tmpdir!"
            fi
            sudo cp -a $OUTPATH $OUT/tmpdir
            sudo mount --bind $OUT/tmpdir/out $OUTPATH
	    if [ $ISFROMSRC -eq 1 ] ; then
                sudo cp $T/build/release/tmpfiles/mdm/mdm.conf $OUTPATH/squashfs-root/etc/mdm/ || return 1
                uninstalldeb "account-plugin-facebook account-plugin-flickr account-plugin-google account-plugin-twitter alacarte appmenu-gtk appmenu-gtk3 appmenu-qt appmenu-qt5 apport apport-symptoms bamfdaemon banshee-extension-soundmenu bison cdparanoia cdrdao compiz compiz-core compiz-gnome compiz-plugins-default curl dconf-tools docbook-xsl flex freepats friends-facebook friends-twitter gir1.2-panelapplet-4.0 gir1.2-rb-3.0 gir1.2-unity-5.0 gnome-applets gnome-applets-data gnome-control-center gnome-control-center-data gnome-control-center-signon gnome-control-center-unity gnome-media gnome-session gnome-session-fallback gnome-user-guide gromit gstreamer0.10-gnomevfs hud humanity-icon-theme icoutils indicator-applet-complete indicator-appmenu indicator-datetime indicator-messages indicator-power indicator-printers indicator-session indicator-sound k3b k3b-data kate-data katepart kde-runtime kde-runtime-data kde-style-oxygen kde-window-manager kde-window-manager-common kdelibs-bin kdelibs5-data kdelibs5-plugins kdoctools kubuntu-debug-installer libattica0.4 libbamf3-1 libbison-dev libcompizconfig0 libdlrestrictions1 libencode-locale-perl libfile-listing-perl libfl-dev libflac++6 libfont-afm-perl libgnome-control-center1 libgnome-media-profiles-3.0-0 libgnome2-canvas-perl libgnome2-perl libgnome2-vfs-perl libgnomevfs2-extra libhtml-form-perl libhtml-format-perl libhtml-parser-perl libhtml-tagset-perl libhtml-tree-perl libhttp-cookies-perl libhttp-daemon-perl libhttp-date-perl libhttp-message-perl libhttp-negotiate-perl libibus-1.0-0 libio-socket-ssl-perl libk3b6 libkactivities-bin libkactivities-models1 libkactivities6 libkatepartinterfaces4 libkcddb4 libkcmutils4 libkde3support4 libkdeclarative5 libkdecorations4abi1 libkdecore5 libkdesu5 libkdeui5 libkdewebkit5 libkdnssd4 libkemoticons4 libkfile4 libkhtml5 libkidletime4 libkio5 libkjsapi4 libkjsembed4 libkmediaplayer4 libknewstuff3-4 libknotifyconfig4 libkntlm4 libkparts4 libkpty4 libkrosscore4 libktexteditor4 libkwineffects1abi4 libkwinglutils1abi1 libkwinnvidiahack4 libkworkspace4abi2 libkxmlrpcclient4 liblwp-mediatypes-perl liblwp-protocol-https-perl libmusicbrainz5-0 libmysqlclient18 libnepomuk4 libnepomukcore4abi1 libnepomukquery4a libnepomukutils4 libnet-http-perl libnet-ssleay-perl libntrack-qt4-1 libntrack0 libnux-4.0-0 libphonon4 libplasma3 libpolkit-qt-1-1 libpoppler-qt4-4 libqapt2 libqapt2-runtime libqca2 libqt4-qt3support libqt4-sql-mysql librhythmbox-core6 libsolid4 libsoprano4 libstreamanalyzer0 libstreams0 libthreadweaver4 libunity-core-6.0-5 libunity-misc4 libunity-webapps0 libvirtodbc0 libwww-perl libwww-robotrules-perl libxcb-damage0 libxml2-utils mysql-common nautilus nepomuk-core nepomuk-core-data notification-daemon ntrack-module-libnl-0 odbcinst odbcinst1debian2 oxygen-icon-theme phonon phonon-backend-gstreamer plasma-scriptengine-javascript python-zeitgeist python3-apport python3-dbus.mainloop.qt python3-distupgrade python3-problem-report python3-pyqt4 python3-sip python3-update-manager qapt-batch rhythmbox rhythmbox-data rhythmbox-mozilla rhythmbox-plugin-cdrecorder rhythmbox-plugin-zeitgeist rhythmbox-plugins rhythmbox-ubuntuone shared-desktop-ontologies soprano-daemon ubiquity-frontend-kde ubuntu-release-upgrader-core unity unity-asset-pool unity-common unity-lens-applications unity-lens-files unity-lens-friends unity-lens-music unity-lens-photos unity-lens-shopping unity-lens-video unity-scope-gdrive unity-scope-musicstores unity-scope-video-remote unity-services unity-webapps-service update-manager-core vcdimager virtuoso-minimal virtuoso-opensource-6.1-bin virtuoso-opensource-6.1-common xul-ext-ubufox zeitgeist zeitgeist-core zeitgeist-datahub build-essential debhelper dh-apparmor dpkg-dev firefox-globalmenu g++ g++-4.7 html2text kbuild libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libmail-sendmail-perl libstdc++6-4.7-dev libsys-hostname-long-perl module-assistant openjdk-6-jre openjdk-6-jre-headless openjdk-6-jre-lib po-debconf thunderbird-globalmenu virtualbox-guest-source xchat-indicator" || return 1
            fi
	fi

        mountdir || return 1

        #Reset sourcelist
        if [ $BUITSTEP -le 35 ] ; then
            echo 35 >$BUILDOSSTEP
            sudo cp $T/build/core/sources.list $OUTPATH/squashfs-root/etc/apt/sources.list.d/official-package-repositories.list || return 1
            sudo cp $T/build/core/cdos-keyring_2014.03.07_all.deb $OUTPATH/squashfs-root/tmp/ || return 1
            sudo chroot $OUTPATH/squashfs-root /bin/bash -c "dpkg -i /tmp/cdos-keyring_2014.03.07_all.deb" || return 1
            sudo rm $OUTPATH/squashfs-root/tmp/cdos-keyring_2014.03.07_all.deb || return 1
            sudo rm $OUTPATH/squashfs-root/etc/apt/sources.list || return 1
            sudo chroot $OUTPATH/squashfs-root /bin/bash -c "apt-get update" || return 1
        fi        

        if [ $BUITSTEP -le 40 ] ; then
            echo 40 >$BUILDOSSTEP
            intkernel || return 1
	    if [ $ISFROMSRC -eq 1 ] ; then
	        uninstalldeb "linux-headers-3.8.0-33 linux-headers-3.8.0-33-generic linux-image-3.8.0-33-generic linux-image-extra-3.8.0-33-generic" || return 1
            fi
        fi

        if [ $BUITSTEP -le 41 ] ; then
            echo 41 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/installtools.sh $OUTPATH $APPPATH || return 1
        fi

        if [ $BUITSTEP -le 42 ] ; then
            echo 42 >$BUILDOSSTEP
            if [ $IS4LENOVO -eq 1 ] ; then
                intnvidiadriver || return 1
            fi
        fi

        if [ $BUITSTEP -le 43 ] ; then
            echo 43 >$BUILDOSSTEP
            if [ $IS4S3G -eq 1 ] ; then
                sudo sh $T/build/core/vendor/install_via_driver.sh $OUTPATH $APPPATH/drivers/s3g/s3g-138603.tar.bz2 $APPPATH/drivers/s3g/patches $KERNEL_VERSION_FULL || return 1
            fi
        fi

        if [ $BUITSTEP -le 44 ] ; then
            echo 44 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/installnouveau.sh $OUTPATH $APPPATH || return 1
        fi
        
        if [ $BUITSTEP -le 45 ] ; then
            echo 45 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/install_via_driver.sh $OUTPATH $APPPATH/drivers/s3g/s3g-138603.tar.bz2 $APPPATH/drivers/s3g/patches $KERNEL_VERSION_FULL || return 1
        fi       

        if [ $BUITSTEP -le 46 ] ; then
            echo 46 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/installxf86-video-ati.sh $OUTPATH $APPPATH || return 1
        fi

        if [ $BUITSTEP -le 47 ] ; then
            echo 47 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/uninstalltools.sh $OUTPATH $APPPATH || return 1
        fi

        #Install popular software
        if [ $BUITSTEP -le 50 ] ; then
            echo 50 >$BUILDOSSTEP
            sudo sh $T/build/release/installzh_CN.sh $OUTPATH $APPPATH || return 1
        fi
        if [ $BUITSTEP -le 51 ] ; then
            echo 51 >$BUILDOSSTEP
            sudo sh $T/build/release/installfirefox.sh $OUTPATH $APPPATH || return 1
        fi
        if [ $BUITSTEP -le 52 ] ; then
            echo 52 >$BUILDOSSTEP
            sudo sh $T/build/release/installvim.sh $OUTPATH $APPPATH || return 1
        fi

        #Install ssh and close root user with ssh authority.
        if [ $BUITSTEP -le 54 ] ; then
            echo 54 >$BUILDOSSTEP
            sudo sh $T/build/release/installssh.sh $OUTPATH $APPPATH || return 1
        fi

        #Change system name in some where. This shell file also will install some software in os source list.
        if [ $BUITSTEP -le 80 ] ; then
            echo 80 >$BUILDOSSTEP
            sudo sh $T/build/release/ubiquity.sh $T/build/release/ $OUTPATH || return 1
        fi

        #Change time zone info
        if [ $BUITSTEP -le 81 ] ; then
            echo 81 >$BUILDOSSTEP
            sudo sh $T/build/release/ubiquity_zoneinfo.sh $OUTPATH || return 1
        fi

        if [ $BUITSTEP -le 100 ] ; then
            echo 100 >$BUILDOSSTEP
            mountdir  || return 1
	    if [ $ISFROMSRC -eq 1 ] ; then
                uninstalldebbyapt "libdnet libgadu3 libhal1 libmagickcore5 libmagickwand5 libprelude2 libunwind8 menu imagemagick-common liblqr-1-0" || return 1
            fi
            uninstallmintdeb || return 1
	    #wangyu: Debs should be removed by the information of Local Application Group
		#The cause of umount failure pacakage is "pidgin"
	    uninstalldeb "cos-meta-codecs libreoffice-base libreoffice-base-core libreoffice-calc libreoffice-emailmerge libreoffice-gnome libreoffice-gtk libreoffice-help-en-gb libreoffice-help-en-us libreoffice-help-zh-cn libreoffice-impress libreoffice-java-common libreoffice-math libreoffice-ogltrans libreoffice-presentation-minimizer libreoffice-writer mythes-en-us banshee gimp gimp-data gimp-help-common gimp-help-en eog transmission-common transmission-gtk brasero vlc vlc-data vlc-nox vlc-plugin-notify vlc-plugin-pulse libvlccore5 libvlc5 brasero-cdrkit brasero-common libbrasero-media3-1" || return 1
            uninstalldeb "xchat xchat-common" || return 1
	    if [ $ISFROMSRC -eq 1 ] ; then
                uninstalldeb "mint-info-xfce banshee-extension-soundmenu" || return 1
            fi
            umountdir || return 1
            uninstalldeb "pidgin pidgin-data pidgin-facebookchat pidgin-libnotify" || return 1
            if [ $ISONLINE == 1 ] ; then
                installdebonline "ubuntu-system-adjustments mint-mdm-themes mint-local-repository mint-flashplugin mint-flashplugin-11 mint-meta-cinnamon mint-meta-core mint-stylish-addon mintdrivers mint-artwork-cinnamon mintsources mintbackup mintstick mintwifi mint-artwork-gnome mint-themes mint-artwork-common mint-backgrounds-olivia mint-x-icons mintsystem mintwelcome mintinstall mintinstall-icons mintnanny mintupdate mintupload mint-info-cinnamon mint-common mint-mirrors mint-translations cinnamon cinnamon-common cinnamon-screensaver nemo nemo-data nemo-share cdos-upgrade"  || return 1
            else
                installdeb "cinnamon cinnamon-common cinnamon-control-center cinnamon-control-center-data cinnamon-screensaver mint-artwork-cinnamon mint-artwork-common mint-artwork-gnome mint-backgrounds-olivia mintbackup mint-common mintdrivers mint-flashplugin mint-flashplugin-11 mint-info-cinnamon mintinstall mintinstall-icons mint-local-repository mint-mdm-themes mint-meta-core mint-mirrors mintnanny mintsources mintstick mint-stylish-addon mintsystem mint-themes mint-translations mintupdate cdos-upgrade mintupload mintwelcome mintwifi mint-x-icons gir1.2-gtop-2.0 libfcitx-qt5-0 gnome-screenshot gnome-system-monitor libcinnamon-control-center1 nemo nemo-data nemo-share ubuntu-system-adjustments libtimezonemap1 gir1.2-timezonemap-1.0 cdospatchmgr gnome-icon-theme-symbolic" || return 1
            fi
            mountdir || return 1
	    if [ $ISFROMSRC -eq 1 ] ; then
	        sudo sed -i 's/^DefaultSession=default.desktop/DefaultSession=cinnamon.desktop/g' $OUTPATH/squashfs-root/usr/share/mdm/defaults.conf || return 1
                sudo sed -i 's/^DefaultSession=default.desktop/DefaultSession=cinnamon.desktop/g' $OUTPATH/squashfs-root/usr/share/ubuntu-system-adjustments/mdm/defaults.conf || return 1
            fi
        fi

	#wangyu: Install apps from local application group.
	if [ $BUITSTEP -le 101 ] ; then
            echo 101 >$BUILDOSSTEP
            HASDEBFILE=0
            DEBTOINSTALL=""
            for line in `find $OUT/$PREAPP/appByLocalGroup/ -name "*.deb"`
	    do
                HASDEBFILE=1
                DEBNAME=`dpkg -f $line Package`
                DEBTOINSTALL=`echo $DEBTOINSTALL $DEBNAME`
                addrepository $line || return 1
    	    done
            if [ $HASDEBFILE == 0 ] ; then
                echo ERROR: No deb file generated. Some error happened in dpkg-buildpackage -d $*
                return 1
            fi
            installdeb "$DEBTOINSTALL" || return 1
            mountdir || return 1
	    if [ ! -x $OUTPATH/squashfs-root/usr/share/apps/goldendict ] ; then
		sudo mkdir $OUTPATH/squashfs-root/usr/share/apps/goldendict
	    fi
	    sudo tar xf $OUT/$PREAPP/appByLocalGroup/GolderDict_dictionary/dicts.tar.gz -C $OUTPATH/squashfs-root/usr/share/apps/goldendict/
	    sudo tar xf $OUT/$PREAPP/appByLocalGroup/GolderDict_dictionary/dictscache.tar.gz -C $OUTPATH/squashfs-root/etc/skel/
	fi

        #Change some icon\theme\applications name and so on.
        if [ $BUITSTEP -le 110 ] ; then
            echo 110 >$BUILDOSSTEP
#           sudo sh $T/build/release/mktheme.sh $OUTPATH || return 1
#	    sudo rm -rf $OUTPATH/squashfs-root/usr/share/themes/Linux\ Mint/
	    uninstalldeb "cinnamon-themes" || return 1
        fi

        #Change some zh_CN LC_MESSAGES
        if [ $BUITSTEP -le 120 ] ; then
            echo 120 >$BUILDOSSTEP
            sudo sh $T/build/release/change_zh_CN.sh $OUTPATH || return 1
        fi

        if [ $BUITSTEP -le 130 ] ; then
            echo 130 >$BUILDOSSTEP
            sudo sh $T/build/release/change_start_menu.sh $OUTPATH || return 1
        fi

        #fix some bugs by change files directly.
        if [ $BUITSTEP -le 140 ] ; then
            echo 140 >$BUILDOSSTEP
            sudo sh $T/build/release/set_username_for_WPS.sh $OUTPATH $OUT/$PREAPP  || return 1
            sudo sh $T/build/release/remove_update_userdir.sh $OUTPATH || return 1
            sudo sh $T/build/release/change_networking.sh $OUTPATH || return 1
            echo change casper username and hostname
            sudo sed -i 's/mint/$OSNAME/' $OUTPATH/squashfs-root/etc/casper.conf
            echo "$OSFULLNAME $OSISSUE \\n \\l" | sudo tee $OUTPATH/squashfs-root/etc/issue
            echo "NAME=\"$OSFULLNAME\"
VERSION=\"$OSVERSION, $OSVERSIONFULLNAME\"
ID=$OSNAME
ID_LIKE=debian
PRETTY_NAME=\"$OSNAME $OSVERSION\"
VERSION_ID=\"$OSVERSION\"" | sudo tee $OUTPATH/squashfs-root/etc/os-release
        fi

        if [ $BUITSTEP -le 148 ] ; then
            echo 148 >$BUILDOSSTEP
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "update-initramfs -u" || return 1
            sudo cp $OUT/out/squashfs-root/boot/vmlinuz-${KERNEL_VERSION_FULL} $OUT/out/$OSNAME/casper/vmlinuz || return 1
            sudo cp $OUT/out/squashfs-root/boot/initrd.img-${KERNEL_VERSION_FULL} $OUT/out/$OSNAME/casper/initrd.lz || return 1
        fi

        #Install deb by apt-get install 
        if [ $BUITSTEP -le 161 ] ; then
            echo 161 >$BUILDOSSTEP
            echo 'Install qt5-qmake and qt5-default g++'
            sudo chroot $OUTPATH/squashfs-root /bin/bash -c "apt-get update"
            sudo chroot $OUTPATH/squashfs-root /bin/bash -c "apt-get -y install qt5-qmake qt5-default g++" || return 1
            echo "Install qt5-qmake and qt5-default successfull~"
            echo "Install cdosfeedback"
            installdeb "cdosfeedback"
            echo "Install cdosfeedback successfull~"
        fi

        if [ $BUITSTEP -le 190 ] ; then
            echo 190 >$BUILDOSSTEP
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd /tmp && rm -r -f *"
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd /home && rm -r -f *"
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get clean"
        fi

        umountdir || return 1

        NOWTIME=`date +%Y%m%d%H%M`
        ISONAME="$OSNAME-i386-$NOWTIME"
        ISOFILENAME="$ISONAME.iso"
        if [ $BUITSTEP -le 200 ] ; then
            echo 200 >$BUILDOSSTEP
            if [ ! -d $OUTPATH/squashfs-root/usr/share/$OSNAME ] ; then
                mkdir -p $OUTPATH/squashfs-root/usr/share$OSNAME/
            fi
            if [ $ISFROMSRC -eq 1 ] ; then
                echo source $NOWTIME | sudo tee $OUTPATH/squashfs-root/usr/share/$OSNAME/buildtime
            else
                echo normal $NOWTIME | sudo tee $OUTPATH/squashfs-root/usr/share/$OSNAME/buildtime
            fi
            mkiso $ISOFILENAME || return 1
        fi
        echo Finish building $OSFULLNAME.

        if [ $BUITSTEP -le 230 ] ; then
            echo 230 >$BUILDOSSTEP
            if [ $IS4DEBUG -eq 1 ] ; then
                ISODEBUGFILENAME="$ISONAME-debug.iso"
                mkiso_debug $ISODEBUGFILENAME $OUTPATH $APPPATH || return 1
                echo Finish building $OSFULLNAME DEBUG.
            fi
        fi

        if [ $BUITSTEP -le 240 ] ; then
            echo 240 >$BUILDOSSTEP
            if [ $IS4OEM -eq 1 ] ; then
                ISODEBUGFILENAME="$ISONAME-oem.iso"
                mkiso_oem $ISODEBUGFILENAME $OUTPATH $APPPATH || return 1
                echo Finish building $OSFULLNAME OEM.
            fi
        fi

        if [ $BUITSTEP -le 250 ] ; then
            echo 250 >$BUILDOSSTEP
            if [ $IS4TEST -eq 1 ] ; then
                #wangyu: Build iso version for test group
                echo "Start building test version..."
                sudo sed -i 's/^managed=false/managed=true/g' $OUTPATH/squashfs-root/etc/NetworkManager/NetworkManager.conf
                echo "End of reconfig /etc/NetworkManager/NetworkManager.conf file..."

                sudo cp $OUT/$PREAPP/fileForTest/rc.local $OUTPATH/squashfs-root/etc/
                echo "End of reconfig /etc/rc.local file..."

		sudo mkdir $OUTPATH/squashfs-root/tmp/fileForTest
                sudo cp -r $OUT/$PREAPP/fileForTest/*/* $OUTPATH/squashfs-root/tmp/fileForTest
                sudo chroot $OUTPATH/squashfs-root /bin/bash -c "cd tmp/fileForTest && dpkg -i -E *.deb" || return 1
		sudo rm -rf $OUTPATH/squashfs-root/tmp/*

            fi
        fi

        if [ $BUITSTEP -le 255 ] ; then
            echo 255 >$BUILDOSSTEP
            if [ $IS4TEST -eq 1 ] ; then
                ISOTESTFILENAME="$ISONAME-test.iso"
                mkiso $ISOTESTFILENAME || return 1
            fi
        fi

        sudo umount -lf $OUTPATH

        echo ======
        echo Tips: You can enter runiso command to run the iso generated.
        echo ======
        echo If you want to build $OSFULLNAME again, you can enter mos 0
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}


function _mbcos()
{
    ISONLINE=0
    BUITSTEP=0
    IS4LENOVO=0
    IS4S3G=0
    IS4TEST=0
    IS4DEBUG=0
    ISFROMSRC=0
    IS4OEM=0
    if [ -e $BUILDOSSTEP ] ; then
        BUITSTEP=`cat $BUILDOSSTEP`
        if [ "$BUITSTEP" -gt 0 ] 2>/dev/null ; then
            BUITSTEP=$BUITSTEP
        else
            BUITSTEP=0
        fi
    fi
    for i in "$@"
    do
        if [ "$i" == "--online" ] ; then
            ISONLINE=1
        elif [ "$i" == "--lenovo" ] ; then
            IS4LENOVO=1
        elif [ "$i" == "--s3g" ] ; then
            IS4S3G=1
	elif [ "$i" == "--test" ] ; then
	    IS4TEST=1
	elif [ "$i" == "--debug" ] ; then
	    IS4DEBUG=1
	elif [ "$i" == "--srcbuild" ] ; then
	    ISFROMSRC=1
	elif [ "$i" == "--oem" ] ; then
	    IS4OEM=1
        else
            if [ "$i" -gt 0 ] 2>/dev/null ; then
                BUITSTEP=$i
            elif [ "$i" == 0 ] ; then
                BUITSTEP=$i
            fi
        fi
    done

    T=$(gettop)
    if [ "$T" ]; then
        #Install zh_CN deb and Input Method deb.
        OUTPATH=$OUT/out
        APPPATH=$OUT/$PREAPP

        if [ ! -e $OUT/out ] ; then
            mkdir -p $OUT/out
        else
            touch $BUILDOSSTEP 2>/dev/null
            if [ $? -ne 0 ] ; then
                Group=`groups $USER | cut -d ' ' -f 1`
                sudo chown $Group.$USER $OUT/out
            fi
        fi

        echo Building $OSFULLNAME...
        if [ $BUITSTEP -le 10 ] ; then
            echo 10 >$BUILDOSSTEP
            getprepkg || return 1
        fi
        if [ $BUITSTEP -le 20 ] ; then
            echo 20 >$BUILDOSSTEP
            checktools || return 1
            createlink || return 1
            mall || return 1
        fi
        if [ $BUITSTEP -le 30 ] ; then
            echo 30 >$BUILDOSSTEP
	    if [ $ISFROMSRC -eq 1 ] ; then
	        mroot || return 1
		mrootbuilder || return 1
                sudo sh $T/build/livecd/create_livecd.sh $OUT/out || return 1
	    else
                uniso || return 1
	   fi
        fi

	if [ $BUITSTEP -le 31 ] ; then
            echo 31 >$BUILDOSSTEP
            if [ -e $OUT/tmpdir ] ; then
                sudo rm -rf $OUT/tmpdir/*
                echo "rm tmpdir!"
            else
                mkdir -p $OUT/tmpdir
                echo "mkdir tmpdir!"
            fi
            sudo cp -a $OUTPATH $OUT/tmpdir
            sudo mount --bind $OUT/tmpdir/out $OUTPATH
	    if [ $ISFROMSRC -eq 1 ] ; then
                sudo cp $T/build/release/tmpfiles/mdm/mdm.conf $OUTPATH/squashfs-root/etc/mdm/ || return 1
                uninstalldeb "account-plugin-facebook account-plugin-flickr account-plugin-google account-plugin-twitter alacarte appmenu-gtk appmenu-gtk3 appmenu-qt appmenu-qt5 apport apport-symptoms bamfdaemon banshee-extension-soundmenu bison cdparanoia cdrdao compiz compiz-core compiz-gnome compiz-plugins-default curl dconf-tools docbook-xsl flex freepats friends-facebook friends-twitter gir1.2-panelapplet-4.0 gir1.2-rb-3.0 gir1.2-unity-5.0 gnome-applets gnome-applets-data gnome-control-center gnome-control-center-data gnome-control-center-signon gnome-control-center-unity gnome-media gnome-session gnome-session-fallback gnome-user-guide gromit gstreamer0.10-gnomevfs hud humanity-icon-theme icoutils indicator-applet-complete indicator-appmenu indicator-datetime indicator-messages indicator-power indicator-printers indicator-session indicator-sound k3b k3b-data kate-data katepart kde-runtime kde-runtime-data kde-style-oxygen kde-window-manager kde-window-manager-common kdelibs-bin kdelibs5-data kdelibs5-plugins kdoctools kubuntu-debug-installer libattica0.4 libbamf3-1 libbison-dev libcompizconfig0 libdlrestrictions1 libencode-locale-perl libfile-listing-perl libfl-dev libflac++6 libfont-afm-perl libgnome-control-center1 libgnome-media-profiles-3.0-0 libgnome2-canvas-perl libgnome2-perl libgnome2-vfs-perl libgnomevfs2-extra libhtml-form-perl libhtml-format-perl libhtml-parser-perl libhtml-tagset-perl libhtml-tree-perl libhttp-cookies-perl libhttp-daemon-perl libhttp-date-perl libhttp-message-perl libhttp-negotiate-perl libibus-1.0-0 libio-socket-ssl-perl libk3b6 libkactivities-bin libkactivities-models1 libkactivities6 libkatepartinterfaces4 libkcddb4 libkcmutils4 libkde3support4 libkdeclarative5 libkdecorations4abi1 libkdecore5 libkdesu5 libkdeui5 libkdewebkit5 libkdnssd4 libkemoticons4 libkfile4 libkhtml5 libkidletime4 libkio5 libkjsapi4 libkjsembed4 libkmediaplayer4 libknewstuff3-4 libknotifyconfig4 libkntlm4 libkparts4 libkpty4 libkrosscore4 libktexteditor4 libkwineffects1abi4 libkwinglutils1abi1 libkwinnvidiahack4 libkworkspace4abi2 libkxmlrpcclient4 liblwp-mediatypes-perl liblwp-protocol-https-perl libmusicbrainz5-0 libmysqlclient18 libnepomuk4 libnepomukcore4abi1 libnepomukquery4a libnepomukutils4 libnet-http-perl libnet-ssleay-perl libntrack-qt4-1 libntrack0 libnux-4.0-0 libphonon4 libplasma3 libpolkit-qt-1-1 libpoppler-qt4-4 libqapt2 libqapt2-runtime libqca2 libqt4-qt3support libqt4-sql-mysql librhythmbox-core6 libsolid4 libsoprano4 libstreamanalyzer0 libstreams0 libthreadweaver4 libunity-core-6.0-5 libunity-misc4 libunity-webapps0 libvirtodbc0 libwww-perl libwww-robotrules-perl libxcb-damage0 libxml2-utils mysql-common nautilus nepomuk-core nepomuk-core-data notification-daemon ntrack-module-libnl-0 odbcinst odbcinst1debian2 oxygen-icon-theme phonon phonon-backend-gstreamer plasma-scriptengine-javascript python-zeitgeist python3-apport python3-dbus.mainloop.qt python3-distupgrade python3-problem-report python3-pyqt4 python3-sip python3-update-manager qapt-batch rhythmbox rhythmbox-data rhythmbox-mozilla rhythmbox-plugin-cdrecorder rhythmbox-plugin-zeitgeist rhythmbox-plugins rhythmbox-ubuntuone shared-desktop-ontologies soprano-daemon ubiquity-frontend-kde ubuntu-release-upgrader-core unity unity-asset-pool unity-common unity-lens-applications unity-lens-files unity-lens-friends unity-lens-music unity-lens-photos unity-lens-shopping unity-lens-video unity-scope-gdrive unity-scope-musicstores unity-scope-video-remote unity-services unity-webapps-service update-manager-core vcdimager virtuoso-minimal virtuoso-opensource-6.1-bin virtuoso-opensource-6.1-common xul-ext-ubufox zeitgeist zeitgeist-core zeitgeist-datahub build-essential debhelper dh-apparmor dpkg-dev firefox-globalmenu g++ g++-4.7 html2text kbuild libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libmail-sendmail-perl libstdc++6-4.7-dev libsys-hostname-long-perl module-assistant openjdk-6-jre openjdk-6-jre-headless openjdk-6-jre-lib po-debconf thunderbird-globalmenu virtualbox-guest-source xchat-indicator" || return 1
            fi
	fi

        mountdir || return 1

        #Reset sourcelist
        if [ $BUITSTEP -le 35 ] ; then
            echo 35 >$BUILDOSSTEP
            sudo cp $T/build/core/sources.list $OUTPATH/squashfs-root/etc/apt/sources.list.d/official-package-repositories.list || return 1
            sudo cp $T/build/core/cdos-keyring_2014.03.07_all.deb $OUTPATH/squashfs-root/tmp/ || return 1
            sudo chroot $OUTPATH/squashfs-root /bin/bash -c "dpkg -i /tmp/cdos-keyring_2014.03.07_all.deb" || return 1
            sudo rm $OUTPATH/squashfs-root/tmp/cdos-keyring_2014.03.07_all.deb || return 1
            sudo rm $OUTPATH/squashfs-root/etc/apt/sources.list || return 1
            sudo chroot $OUTPATH/squashfs-root /bin/bash -c "apt-get update" || return 1
        fi        

        if [ $BUITSTEP -le 40 ] ; then
            echo 40 >$BUILDOSSTEP
            intkernel || return 1
	    if [ $ISFROMSRC -eq 1 ] ; then
	        uninstalldeb "linux-headers-3.8.0-33 linux-headers-3.8.0-33-generic linux-image-3.8.0-33-generic linux-image-extra-3.8.0-33-generic" || return 1
            fi
        fi

        if [ $BUITSTEP -le 41 ] ; then
            echo 41 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/installtools.sh $OUTPATH $APPPATH || return 1
        fi

        if [ $BUITSTEP -le 42 ] ; then
            echo 42 >$BUILDOSSTEP
            if [ $IS4LENOVO -eq 1 ] ; then
                intnvidiadriver || return 1
            fi
        fi

        if [ $BUITSTEP -le 43 ] ; then
            echo 43 >$BUILDOSSTEP
            if [ $IS4S3G -eq 1 ] ; then
                sudo sh $T/build/core/vendor/install_via_driver.sh $OUTPATH $APPPATH/drivers/s3g/s3g-138603.tar.bz2 $APPPATH/drivers/s3g/patches $KERNEL_VERSION_FULL || return 1
            fi
        fi

        if [ $BUITSTEP -le 44 ] ; then
            echo 44 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/installnouveau.sh $OUTPATH $APPPATH || return 1
        fi
        
        if [ $BUITSTEP -le 45 ] ; then
            echo 45 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/install_via_driver.sh $OUTPATH $APPPATH/drivers/s3g/s3g-138603.tar.bz2 $APPPATH/drivers/s3g/patches $KERNEL_VERSION_FULL || return 1
        fi       

        if [ $BUITSTEP -le 46 ] ; then
            echo 46 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/installxf86-video-ati.sh $OUTPATH $APPPATH || return 1
        fi

        if [ $BUITSTEP -le 47 ] ; then
            echo 47 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/uninstalltools.sh $OUTPATH $APPPATH || return 1
        fi

        #Install popular software
        if [ $BUITSTEP -le 50 ] ; then
            echo 50 >$BUILDOSSTEP
            sudo sh $T/build/release/installzh_CN.sh $OUTPATH $APPPATH || return 1
        fi
        if [ $BUITSTEP -le 51 ] ; then
            echo 51 >$BUILDOSSTEP
            sudo sh $T/build/release/installfirefox.sh $OUTPATH $APPPATH || return 1
        fi
        if [ $BUITSTEP -le 52 ] ; then
            echo 52 >$BUILDOSSTEP
            sudo sh $T/build/release/installvim.sh $OUTPATH $APPPATH || return 1
        fi

        #Install ssh and close root user with ssh authority.
        if [ $BUITSTEP -le 54 ] ; then
            echo 54 >$BUILDOSSTEP
            sudo sh $T/build/release/installssh.sh $OUTPATH $APPPATH || return 1
        fi

        #Change system name in some where. This shell file also will install some software in os source list.
        if [ $BUITSTEP -le 80 ] ; then
            echo 80 >$BUILDOSSTEP
            sudo sh $T/build/release/ubiquity.sh $T/build/release/ $OUTPATH || return 1
        fi

        #Change time zone info
        if [ $BUITSTEP -le 81 ] ; then
            echo 81 >$BUILDOSSTEP
            sudo sh $T/build/release/ubiquity_zoneinfo.sh $OUTPATH || return 1
        fi

        if [ $BUITSTEP -le 100 ] ; then
            echo 100 >$BUILDOSSTEP
            mountdir  || return 1
	    if [ $ISFROMSRC -eq 1 ] ; then
                uninstalldebbyapt "libdnet libgadu3 libhal1 libmagickcore5 libmagickwand5 libprelude2 libunwind8 menu imagemagick-common liblqr-1-0" || return 1
            fi
            uninstallmintdeb || return 1
	    #wangyu: Debs should be removed by the information of Local Application Group
		#The cause of umount failure pacakage is "pidgin"
	    uninstalldeb "cos-meta-codecs libreoffice-base libreoffice-base-core libreoffice-calc libreoffice-emailmerge libreoffice-gnome libreoffice-gtk libreoffice-help-en-gb libreoffice-help-en-us libreoffice-help-zh-cn libreoffice-impress libreoffice-java-common libreoffice-math libreoffice-ogltrans libreoffice-presentation-minimizer libreoffice-writer libreoffice-draw mythes-en-us banshee gimp gimp-data gimp-help-common gimp-help-en eog transmission-common transmission-gtk brasero vlc vlc-data vlc-nox vlc-plugin-notify vlc-plugin-pulse libvlccore5 libvlc5 brasero-cdrkit brasero-common libbrasero-media3-1" || return 1
            uninstalldeb "xchat xchat-common" || return 1
	    if [ $ISFROMSRC -eq 1 ] ; then
                uninstalldeb "mint-info-xfce banshee-extension-soundmenu" || return 1
            fi
            umountdir || return 1
            uninstalldeb "pidgin pidgin-data pidgin-facebookchat pidgin-libnotify" || return 1
            if [ $ISONLINE == 1 ] ; then
                installdebonline "ubuntu-system-adjustments mint-mdm-themes mint-local-repository mint-flashplugin mint-flashplugin-11 mint-meta-cinnamon mint-meta-core mint-stylish-addon mintdrivers mint-artwork-cinnamon mintsources mintbackup mintstick mintwifi mint-artwork-gnome mint-themes mint-artwork-common mint-backgrounds-olivia mint-x-icons mintsystem mintwelcome mintinstall mintinstall-icons mintnanny mintupdate mintupload mint-info-cinnamon mint-common mint-mirrors mint-translations cinnamon cinnamon-common cinnamon-screensaver nemo nemo-data nemo-share cdos-upgrade"  || return 1
            else
                installdeb "cinnamon cinnamon-common cinnamon-control-center cinnamon-control-center-data cinnamon-screensaver mint-artwork-cinnamon mint-artwork-common mint-artwork-gnome mint-backgrounds-olivia mintbackup mint-common mintdrivers mint-flashplugin mint-flashplugin-11 mint-info-cinnamon mintinstall mintinstall-icons mint-local-repository mint-mdm-themes mint-meta-core mint-mirrors mintnanny mintsources mintstick mint-stylish-addon mintsystem mint-themes mint-translations mintupdate cdos-upgrade mintupload mintwelcome mintwifi mint-x-icons gir1.2-gtop-2.0 libfcitx-qt5-0 gnome-screenshot gnome-system-monitor libcinnamon-control-center1 nemo nemo-data nemo-share ubuntu-system-adjustments libtimezonemap1 gir1.2-timezonemap-1.0 cdospatchmgr gnome-icon-theme-symbolic" || return 1
            fi
            mountdir || return 1
	    if [ $ISFROMSRC -eq 1 ] ; then
	        sudo sed -i 's/^DefaultSession=default.desktop/DefaultSession=cinnamon.desktop/g' $OUTPATH/squashfs-root/usr/share/mdm/defaults.conf || return 1
                sudo sed -i 's/^DefaultSession=default.desktop/DefaultSession=cinnamon.desktop/g' $OUTPATH/squashfs-root/usr/share/ubuntu-system-adjustments/mdm/defaults.conf || return 1
            fi
        fi

	#wangyu: Install apps from local application group.
	if [ $BUITSTEP -le 101 ] ; then
            echo 101 >$BUILDOSSTEP
            HASDEBFILE=0
            DEBTOINSTALL=""
            for line in `find $OUT/$PREAPP/appByLocalGroup/ -name "*.deb"`
	    do
                HASDEBFILE=1
                DEBNAME=`dpkg -f $line Package`
                DEBTOINSTALL=`echo $DEBTOINSTALL $DEBNAME`
                addrepository $line || return 1
    	    done
            if [ $HASDEBFILE == 0 ] ; then
                echo ERROR: No deb file generated. Some error happened in dpkg-buildpackage -d $*
                return 1
            fi
            installdeb "$DEBTOINSTALL" || return 1
            mountdir || return 1
	    if [ ! -x $OUTPATH/squashfs-root/usr/share/apps/goldendict ] ; then
		sudo mkdir $OUTPATH/squashfs-root/usr/share/apps/goldendict
	    fi
	    sudo tar xf $OUT/$PREAPP/appByLocalGroup/GolderDict_dictionary/dicts.tar.gz -C $OUTPATH/squashfs-root/usr/share/apps/goldendict/
	    sudo tar xf $OUT/$PREAPP/appByLocalGroup/GolderDict_dictionary/dictscache.tar.gz -C $OUTPATH/squashfs-root/etc/skel/
	fi

        #Change some icon\theme\applications name and so on.
        if [ $BUITSTEP -le 110 ] ; then
            echo 110 >$BUILDOSSTEP
#           sudo sh $T/build/release/mktheme.sh $OUTPATH || return 1
#	    sudo rm -rf $OUTPATH/squashfs-root/usr/share/themes/Linux\ Mint/
	    uninstalldeb "cinnamon-themes" || return 1
        fi

        #Change some zh_CN LC_MESSAGES
        if [ $BUITSTEP -le 120 ] ; then
            echo 120 >$BUILDOSSTEP
            sudo sh $T/build/release/change_zh_CN.sh $OUTPATH || return 1
        fi

        if [ $BUITSTEP -le 130 ] ; then
            echo 130 >$BUILDOSSTEP
            sudo sh $T/build/release/change_start_menu.sh $OUTPATH || return 1
        fi

        #fix some bugs by change files directly.
        if [ $BUITSTEP -le 140 ] ; then
            echo 140 >$BUILDOSSTEP
            sudo sh $T/build/release/set_username_for_WPS.sh $OUTPATH $OUT/$PREAPP  || return 1
            sudo sh $T/build/release/remove_update_userdir.sh $OUTPATH || return 1
            sudo sh $T/build/release/change_networking.sh $OUTPATH || return 1
            echo change casper username and hostname
            sudo sed -i 's/mint/$OSNAME/' $OUTPATH/squashfs-root/etc/casper.conf
            echo "$OSFULLNAME $OSISSUE \\n \\l" | sudo tee $OUTPATH/squashfs-root/etc/issue
            echo "NAME=\"$OSFULLNAME\"
VERSION=\"$OSVERSION, $OSVERSIONFULLNAME\"
ID=$OSNAME
ID_LIKE=debian
PRETTY_NAME=\"$OSNAME $OSVERSION\"
VERSION_ID=\"$OSVERSION\"" | sudo tee $OUTPATH/squashfs-root/etc/os-release
        fi

        if [ $BUITSTEP -le 148 ] ; then
            echo 148 >$BUILDOSSTEP
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "update-initramfs -u" || return 1
            sudo cp $OUT/out/squashfs-root/boot/vmlinuz-${KERNEL_VERSION_FULL} $OUT/out/$OSNAME/casper/vmlinuz || return 1
            sudo cp $OUT/out/squashfs-root/boot/initrd.img-${KERNEL_VERSION_FULL} $OUT/out/$OSNAME/casper/initrd.lz || return 1
        fi

        #Install deb by apt-get install 
        if [ $BUITSTEP -le 161 ] ; then
            echo 161 >$BUILDOSSTEP
            echo 'Install qt5-qmake and qt5-default g++'
            sudo chroot $OUTPATH/squashfs-root /bin/bash -c "apt-get update"
            sudo chroot $OUTPATH/squashfs-root /bin/bash -c "apt-get -y install qt5-qmake qt5-default g++" || return 1
            echo "Install qt5-qmake and qt5-default successfull~"
            echo "Install cdosfeedback"
            installdeb "cdosfeedback"
            echo "Install cdosfeedback successfull~"
        fi

        if [ $BUITSTEP -le 190 ] ; then
            echo 190 >$BUILDOSSTEP
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd /tmp && rm -r -f *"
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd /home && rm -r -f *"
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get clean"
        fi

        umountdir || return 1

        NOWTIME=`date +%Y%m%d%H%M`
        ISONAME="$OSNAME-i386-$NOWTIME"
        ISOFILENAME="$ISONAME.iso"
        if [ $BUITSTEP -le 200 ] ; then
            echo 200 >$BUILDOSSTEP
            if [ ! -d $OUTPATH/squashfs-root/usr/share/$OSNAME ] ; then
                mkdir -p $OUTPATH/squashfs-root/usr/share$OSNAME/
            fi
            if [ $ISFROMSRC -eq 1 ] ; then
                echo source $NOWTIME | sudo tee $OUTPATH/squashfs-root/usr/share/$OSNAME/buildtime
            else
                echo normal $NOWTIME | sudo tee $OUTPATH/squashfs-root/usr/share/$OSNAME/buildtime
            fi
            mkiso $ISOFILENAME || return 1
        fi
        echo Finish building $OSFULLNAME.

        if [ $BUITSTEP -le 230 ] ; then
            echo 230 >$BUILDOSSTEP
            if [ $IS4DEBUG -eq 1 ] ; then
                ISODEBUGFILENAME="$ISONAME-debug.iso"
                mkiso_debug $ISODEBUGFILENAME $OUTPATH $APPPATH || return 1
                echo Finish building $OSFULLNAME DEBUG.
            fi
        fi

        if [ $BUITSTEP -le 240 ] ; then
            echo 240 >$BUILDOSSTEP
            if [ $IS4OEM -eq 1 ] ; then
                ISODEBUGFILENAME="$ISONAME-oem.iso"
                mkiso_oem $ISODEBUGFILENAME $OUTPATH $APPPATH || return 1
                echo Finish building $OSFULLNAME OEM.
            fi
        fi

        if [ $BUITSTEP -le 250 ] ; then
            echo 250 >$BUILDOSSTEP
            if [ $IS4TEST -eq 1 ] ; then
                #wangyu: Build iso version for test group
                echo "Start building test version..."
                sudo sed -i 's/^managed=false/managed=true/g' $OUTPATH/squashfs-root/etc/NetworkManager/NetworkManager.conf
                echo "End of reconfig /etc/NetworkManager/NetworkManager.conf file..."

                sudo cp $OUT/$PREAPP/fileForTest/rc.local $OUTPATH/squashfs-root/etc/
                echo "End of reconfig /etc/rc.local file..."

		sudo mkdir $OUTPATH/squashfs-root/tmp/fileForTest
                sudo cp -r $OUT/$PREAPP/fileForTest/*/* $OUTPATH/squashfs-root/tmp/fileForTest
                sudo chroot $OUTPATH/squashfs-root /bin/bash -c "cd tmp/fileForTest && dpkg -i -E *.deb" || return 1
		sudo rm -rf $OUTPATH/squashfs-root/tmp/*

            fi
        fi

        if [ $BUITSTEP -le 255 ] ; then
            echo 255 >$BUILDOSSTEP
            if [ $IS4TEST -eq 1 ] ; then
                ISOTESTFILENAME="$ISONAME-test.iso"
                mkiso $ISOTESTFILENAME || return 1
            fi
        fi

        sudo umount -lf $OUTPATH

        echo ======
        echo Tips: You can enter runiso command to run the iso generated.
        echo ======
        echo If you want to build $OSFULLNAME again, you can enter mos 0
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function mos()
{
    NOWTIME=`date +%Y%m%d%H%M`
    _mos $* | tee /tmp/mos_${NOWTIME}.log
}

function _mos()
{
    ISONLINE=0
    BUITSTEP=0
    IS4LENOVO=0
    IS4S3G=0
    IS4TEST=0
    IS4DEBUG=0
    ISFROMSRC=0
    IS4OEM=0
    if [ -e $BUILDOSSTEP ] ; then
        BUITSTEP=`cat $BUILDOSSTEP`
        if [ "$BUITSTEP" -gt 0 ] 2>/dev/null ; then
            BUITSTEP=$BUITSTEP
        else
            BUITSTEP=0
        fi
    fi
    for i in "$@"
    do
        if [ "$i" == "--online" ] ; then
            ISONLINE=1
        elif [ "$i" == "--lenovo" ] ; then
            IS4LENOVO=1
        elif [ "$i" == "--s3g" ] ; then
            IS4S3G=1
	elif [ "$i" == "--test" ] ; then
	    IS4TEST=1
	elif [ "$i" == "--debug" ] ; then
	    IS4DEBUG=1
	elif [ "$i" == "--srcbuild" ] ; then
	    ISFROMSRC=1
	elif [ "$i" == "--oem" ] ; then
	    IS4OEM=1
        else
            if [ "$i" -gt 0 ] 2>/dev/null ; then
                BUITSTEP=$i
            elif [ "$i" == 0 ] ; then
                BUITSTEP=$i
            fi
        fi
    done

    T=$(gettop)
    if [ "$T" ]; then
        #Install zh_CN deb and Input Method deb.
        OUTPATH=$OUT/out
        APPPATH=$OUT/$PREAPP

        if [ ! -e $OUT/out ] ; then
            mkdir -p $OUT/out
        else
            touch $BUILDOSSTEP 2>/dev/null
            if [ $? -ne 0 ] ; then
                Group=`groups $USER | cut -d ' ' -f 1`
                sudo chown $Group.$USER $OUT/out
            fi
        fi

        echo Building $OSFULLNAME...
        if [ $BUITSTEP -le 10 ] ; then
            echo 10 >$BUILDOSSTEP
            getprepkg || return 1
        fi
        if [ $BUITSTEP -le 20 ] ; then
            echo 20 >$BUILDOSSTEP
            checktools || return 1
            createlink || return 1
            mall || return 1
        fi
        if [ $BUITSTEP -le 30 ] ; then
            echo 30 >$BUILDOSSTEP
	    if [ $ISFROMSRC -eq 1 ] ; then
	        mroot || return 1
		mrootbuilder || return 1
                sudo sh $T/build/livecd/create_livecd.sh $OUT/out || return 1
	    else
                uniso || return 1
	   fi
        fi

	if [ $BUITSTEP -le 31 ] ; then
            echo 31 >$BUILDOSSTEP
	    if [ $ISFROMSRC -eq 1 ] ; then
                sudo cp $T/build/release/tmpfiles/mdm/mdm.conf $OUTPATH/squashfs-root/etc/mdm/ || return 1
                uninstalldeb "account-plugin-facebook account-plugin-flickr account-plugin-google account-plugin-twitter alacarte appmenu-gtk appmenu-gtk3 appmenu-qt appmenu-qt5 apport apport-symptoms bamfdaemon banshee-extension-soundmenu bison cdparanoia cdrdao compiz compiz-core compiz-gnome compiz-plugins-default curl dconf-tools docbook-xsl flex freepats friends-facebook friends-twitter gir1.2-panelapplet-4.0 gir1.2-rb-3.0 gir1.2-unity-5.0 gnome-applets gnome-applets-data gnome-control-center gnome-control-center-data gnome-control-center-signon gnome-control-center-unity gnome-media gnome-session gnome-session-fallback gnome-user-guide gromit gstreamer0.10-gnomevfs hud humanity-icon-theme icoutils indicator-applet-complete indicator-appmenu indicator-datetime indicator-messages indicator-power indicator-printers indicator-session indicator-sound k3b k3b-data kate-data katepart kde-runtime kde-runtime-data kde-style-oxygen kde-window-manager kde-window-manager-common kdelibs-bin kdelibs5-data kdelibs5-plugins kdoctools kubuntu-debug-installer libattica0.4 libbamf3-1 libbison-dev libcompizconfig0 libdlrestrictions1 libencode-locale-perl libfile-listing-perl libfl-dev libflac++6 libfont-afm-perl libgnome-control-center1 libgnome-media-profiles-3.0-0 libgnome2-canvas-perl libgnome2-perl libgnome2-vfs-perl libgnomevfs2-extra libhtml-form-perl libhtml-format-perl libhtml-parser-perl libhtml-tagset-perl libhtml-tree-perl libhttp-cookies-perl libhttp-daemon-perl libhttp-date-perl libhttp-message-perl libhttp-negotiate-perl libibus-1.0-0 libio-socket-ssl-perl libk3b6 libkactivities-bin libkactivities-models1 libkactivities6 libkatepartinterfaces4 libkcddb4 libkcmutils4 libkde3support4 libkdeclarative5 libkdecorations4abi1 libkdecore5 libkdesu5 libkdeui5 libkdewebkit5 libkdnssd4 libkemoticons4 libkfile4 libkhtml5 libkidletime4 libkio5 libkjsapi4 libkjsembed4 libkmediaplayer4 libknewstuff3-4 libknotifyconfig4 libkntlm4 libkparts4 libkpty4 libkrosscore4 libktexteditor4 libkwineffects1abi4 libkwinglutils1abi1 libkwinnvidiahack4 libkworkspace4abi2 libkxmlrpcclient4 liblwp-mediatypes-perl liblwp-protocol-https-perl libmusicbrainz5-0 libmysqlclient18 libnepomuk4 libnepomukcore4abi1 libnepomukquery4a libnepomukutils4 libnet-http-perl libnet-ssleay-perl libntrack-qt4-1 libntrack0 libnux-4.0-0 libphonon4 libplasma3 libpolkit-qt-1-1 libpoppler-qt4-4 libqapt2 libqapt2-runtime libqca2 libqt4-qt3support libqt4-sql-mysql librhythmbox-core6 libsolid4 libsoprano4 libstreamanalyzer0 libstreams0 libthreadweaver4 libunity-core-6.0-5 libunity-misc4 libunity-webapps0 libvirtodbc0 libwww-perl libwww-robotrules-perl libxcb-damage0 libxml2-utils mysql-common nautilus nepomuk-core nepomuk-core-data notification-daemon ntrack-module-libnl-0 odbcinst odbcinst1debian2 oxygen-icon-theme phonon phonon-backend-gstreamer plasma-scriptengine-javascript python-zeitgeist python3-apport python3-dbus.mainloop.qt python3-distupgrade python3-problem-report python3-pyqt4 python3-sip python3-update-manager qapt-batch rhythmbox rhythmbox-data rhythmbox-mozilla rhythmbox-plugin-cdrecorder rhythmbox-plugin-zeitgeist rhythmbox-plugins rhythmbox-ubuntuone shared-desktop-ontologies soprano-daemon ubiquity-frontend-kde ubuntu-release-upgrader-core unity unity-asset-pool unity-common unity-lens-applications unity-lens-files unity-lens-friends unity-lens-music unity-lens-photos unity-lens-shopping unity-lens-video unity-scope-gdrive unity-scope-musicstores unity-scope-video-remote unity-services unity-webapps-service update-manager-core vcdimager virtuoso-minimal virtuoso-opensource-6.1-bin virtuoso-opensource-6.1-common xul-ext-ubufox zeitgeist zeitgeist-core zeitgeist-datahub build-essential debhelper dh-apparmor dpkg-dev firefox-globalmenu g++ g++-4.7 html2text kbuild libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libmail-sendmail-perl libstdc++6-4.7-dev libsys-hostname-long-perl module-assistant openjdk-6-jre openjdk-6-jre-headless openjdk-6-jre-lib po-debconf thunderbird-globalmenu virtualbox-guest-source xchat-indicator" || return 1
            fi
	fi

        mountdir || return 1

        #Reset sourcelist
        if [ $BUITSTEP -le 35 ] ; then
            echo 35 >$BUILDOSSTEP
            sudo cp $T/build/core/sources.list $OUTPATH/squashfs-root/etc/apt/sources.list.d/official-package-repositories.list || return 1
            sudo cp $T/build/core/cdos-keyring_2014.03.07_all.deb $OUTPATH/squashfs-root/tmp/ || return 1
            sudo chroot $OUTPATH/squashfs-root /bin/bash -c "dpkg -i /tmp/cdos-keyring_2014.03.07_all.deb" || return 1
            sudo rm $OUTPATH/squashfs-root/tmp/cdos-keyring_2014.03.07_all.deb || return 1
            sudo rm $OUTPATH/squashfs-root/etc/apt/sources.list || return 1
            sudo chroot $OUTPATH/squashfs-root /bin/bash -c "apt-get update" || return 1
        fi        

        if [ $BUITSTEP -le 40 ] ; then
            echo 40 >$BUILDOSSTEP
            intkernel || return 1
	    if [ $ISFROMSRC -eq 1 ] ; then
	        uninstalldeb "linux-headers-3.8.0-33 linux-headers-3.8.0-33-generic linux-image-3.8.0-33-generic linux-image-extra-3.8.0-33-generic" || return 1
            fi
        fi

        if [ $BUITSTEP -le 41 ] ; then
            echo 41 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/installtools.sh $OUTPATH $APPPATH || return 1
        fi

        if [ $BUITSTEP -le 42 ] ; then
            echo 42 >$BUILDOSSTEP
            if [ $IS4LENOVO -eq 1 ] ; then
                intnvidiadriver || return 1
            fi
        fi

        if [ $BUITSTEP -le 43 ] ; then
            echo 43 >$BUILDOSSTEP
            if [ $IS4S3G -eq 1 ] ; then
                sudo sh $T/build/core/vendor/install_via_driver.sh $OUTPATH $APPPATH/drivers/s3g/s3g-138603.tar.bz2 $APPPATH/drivers/s3g/patches $KERNEL_VERSION_FULL || return 1
            fi
        fi

        if [ $BUITSTEP -le 44 ] ; then
            echo 44 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/installnouveau.sh $OUTPATH $APPPATH || return 1
        fi
        
        if [ $BUITSTEP -le 45 ] ; then
            echo 45 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/install_via_driver.sh $OUTPATH $APPPATH/drivers/s3g/s3g-138603.tar.bz2 $APPPATH/drivers/s3g/patches $KERNEL_VERSION_FULL || return 1
        fi       

        if [ $BUITSTEP -le 46 ] ; then
            echo 46 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/installxf86-video-ati.sh $OUTPATH $APPPATH || return 1
        fi

        if [ $BUITSTEP -le 47 ] ; then
            echo 47 >$BUILDOSSTEP
            sudo sh $T/build/core/vendor/uninstalltools.sh $OUTPATH $APPPATH || return 1
        fi

        #Install popular software
        if [ $BUITSTEP -le 50 ] ; then
            echo 50 >$BUILDOSSTEP
            sudo sh $T/build/release/installzh_CN.sh $OUTPATH $APPPATH || return 1
        fi
        if [ $BUITSTEP -le 51 ] ; then
            echo 51 >$BUILDOSSTEP
            sudo sh $T/build/release/installfirefox.sh $OUTPATH $APPPATH || return 1
        fi
        if [ $BUITSTEP -le 52 ] ; then
            echo 52 >$BUILDOSSTEP
            sudo sh $T/build/release/installvim.sh $OUTPATH $APPPATH || return 1
        fi

        #Install ssh and close root user with ssh authority.
        if [ $BUITSTEP -le 54 ] ; then
            echo 54 >$BUILDOSSTEP
            sudo sh $T/build/release/installssh.sh $OUTPATH $APPPATH || return 1
        fi

        #Change system name in some where. This shell file also will install some software in os source list.
        if [ $BUITSTEP -le 80 ] ; then
            echo 80 >$BUILDOSSTEP
            sudo sh $T/build/release/ubiquity.sh $T/build/release/ $OUTPATH || return 1
        fi

        #Change time zone info
        if [ $BUITSTEP -le 81 ] ; then
            echo 81 >$BUILDOSSTEP
            sudo sh $T/build/release/ubiquity_zoneinfo.sh $OUTPATH || return 1
        fi

        if [ $BUITSTEP -le 100 ] ; then
            echo 100 >$BUILDOSSTEP
            mountdir  || return 1
	    if [ $ISFROMSRC -eq 1 ] ; then
                uninstalldebbyapt "libdnet libgadu3 libhal1 libmagickcore5 libmagickwand5 libprelude2 libunwind8 menu imagemagick-common liblqr-1-0" || return 1
            fi
            uninstallmintdeb || return 1
	    #wangyu: Debs should be removed by the information of Local Application Group
		#The cause of umount failure pacakage is "pidgin"
	    uninstalldeb "cos-meta-codecs libreoffice-base libreoffice-base-core libreoffice-calc libreoffice-emailmerge libreoffice-gnome libreoffice-gtk libreoffice-help-en-gb libreoffice-help-en-us libreoffice-help-zh-cn libreoffice-impress libreoffice-java-common libreoffice-math libreoffice-ogltrans libreoffice-presentation-minimizer libreoffice-writer mythes-en-us banshee gimp gimp-data gimp-help-common gimp-help-en eog transmission-common transmission-gtk brasero vlc vlc-data vlc-nox vlc-plugin-notify vlc-plugin-pulse libvlccore5 libvlc5 brasero-cdrkit brasero-common libbrasero-media3-1" || return 1
            uninstalldeb "xchat xchat-common" || return 1
	    if [ $ISFROMSRC -eq 1 ] ; then
                uninstalldeb "mint-info-xfce banshee-extension-soundmenu" || return 1
            fi
            umountdir || return 1
            uninstalldeb "pidgin pidgin-data pidgin-facebookchat pidgin-libnotify" || return 1
            if [ $ISONLINE == 1 ] ; then
                installdebonline "ubuntu-system-adjustments mint-mdm-themes mint-local-repository mint-flashplugin mint-flashplugin-11 mint-meta-cinnamon mint-meta-core mint-stylish-addon mintdrivers mint-artwork-cinnamon mintsources mintbackup mintstick mintwifi mint-artwork-gnome mint-themes mint-artwork-common mint-backgrounds-olivia mint-x-icons mintsystem mintwelcome mintinstall mintinstall-icons mintnanny mintupdate mintupload mint-info-cinnamon mint-common mint-mirrors mint-translations cinnamon cinnamon-common cinnamon-screensaver nemo nemo-data nemo-share cdos-upgrade"  || return 1
            else
                installdeb "cinnamon cinnamon-common cinnamon-control-center cinnamon-control-center-data cinnamon-screensaver mint-artwork-cinnamon mint-artwork-common mint-artwork-gnome mint-backgrounds-olivia mintbackup mint-common mintdrivers mint-flashplugin mint-flashplugin-11 mint-info-cinnamon mintinstall mintinstall-icons mint-local-repository mint-mdm-themes mint-meta-core mint-mirrors mintnanny mintsources mintstick mint-stylish-addon mintsystem mint-themes mint-translations mintupdate cdos-upgrade mintupload mintwelcome mintwifi mint-x-icons gir1.2-gtop-2.0 libfcitx-qt5-0 gnome-screenshot gnome-system-monitor libcinnamon-control-center1 nemo nemo-data nemo-share ubuntu-system-adjustments libtimezonemap1 gir1.2-timezonemap-1.0 cdospatchmgr gnome-icon-theme-symbolic" || return 1
            fi
            mountdir || return 1
	    if [ $ISFROMSRC -eq 1 ] ; then
	        sudo sed -i 's/^DefaultSession=default.desktop/DefaultSession=cinnamon.desktop/g' $OUTPATH/squashfs-root/usr/share/mdm/defaults.conf || return 1
                sudo sed -i 's/^DefaultSession=default.desktop/DefaultSession=cinnamon.desktop/g' $OUTPATH/squashfs-root/usr/share/ubuntu-system-adjustments/mdm/defaults.conf || return 1
            fi
        fi

	#wangyu: Install apps from local application group.
	if [ $BUITSTEP -le 101 ] ; then
            echo 101 >$BUILDOSSTEP
            HASDEBFILE=0
            DEBTOINSTALL=""
            for line in `find $OUT/$PREAPP/appByLocalGroup/ -name "*.deb"`
	    do
                HASDEBFILE=1
                DEBNAME=`dpkg -f $line Package`
                DEBTOINSTALL=`echo $DEBTOINSTALL $DEBNAME`
                addrepository $line || return 1
    	    done
            if [ $HASDEBFILE == 0 ] ; then
                echo ERROR: No deb file generated. Some error happened in dpkg-buildpackage -d $*
                return 1
            fi
            installdeb "$DEBTOINSTALL" || return 1
            mountdir || return 1
	    if [ ! -x $OUTPATH/squashfs-root/usr/share/apps/goldendict ] ; then
		sudo mkdir $OUTPATH/squashfs-root/usr/share/apps/goldendict
	    fi
	    sudo tar xf $OUT/$PREAPP/appByLocalGroup/GolderDict_dictionary/dicts.tar.gz -C $OUTPATH/squashfs-root/usr/share/apps/goldendict/
	    sudo tar xf $OUT/$PREAPP/appByLocalGroup/GolderDict_dictionary/dictscache.tar.gz -C $OUTPATH/squashfs-root/etc/skel/
	fi

        #Change some icon\theme\applications name and so on.
        if [ $BUITSTEP -le 110 ] ; then
            echo 110 >$BUILDOSSTEP
#           sudo sh $T/build/release/mktheme.sh $OUTPATH || return 1
#	    sudo rm -rf $OUTPATH/squashfs-root/usr/share/themes/Linux\ Mint/
	    uninstalldeb "cinnamon-themes" || return 1
        fi

        #Change some zh_CN LC_MESSAGES
        if [ $BUITSTEP -le 120 ] ; then
            echo 120 >$BUILDOSSTEP
            sudo sh $T/build/release/change_zh_CN.sh $OUTPATH || return 1
        fi

        if [ $BUITSTEP -le 130 ] ; then
            echo 130 >$BUILDOSSTEP
            sudo sh $T/build/release/change_start_menu.sh $OUTPATH || return 1
        fi

        #fix some bugs by change files directly.
        if [ $BUITSTEP -le 140 ] ; then
            echo 140 >$BUILDOSSTEP
            sudo sh $T/build/release/set_username_for_WPS.sh $OUTPATH $OUT/$PREAPP  || return 1
            sudo sh $T/build/release/remove_update_userdir.sh $OUTPATH || return 1
            sudo sh $T/build/release/change_networking.sh $OUTPATH || return 1
            echo change casper username and hostname
            sudo sed -i 's/mint/$OSNAME/' $OUTPATH/squashfs-root/etc/casper.conf
            echo "$OSFULLNAME $OSISSUE \\n \\l" | sudo tee $OUTPATH/squashfs-root/etc/issue
            echo "NAME=\"$OSFULLNAME\"
VERSION=\"$OSVERSION, $OSVERSIONFULLNAME\"
ID=$OSNAME
ID_LIKE=debian
PRETTY_NAME=\"$OSNAME $OSVERSION\"
VERSION_ID=\"$OSVERSION\"" | sudo tee $OUTPATH/squashfs-root/etc/os-release
        fi

        if [ $BUITSTEP -le 148 ] ; then
            echo 148 >$BUILDOSSTEP
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "update-initramfs -u" || return 1
            sudo cp $OUT/out/squashfs-root/boot/vmlinuz-${KERNEL_VERSION_FULL} $OUT/out/$OSNAME/casper/vmlinuz || return 1
            sudo cp $OUT/out/squashfs-root/boot/initrd.img-${KERNEL_VERSION_FULL} $OUT/out/$OSNAME/casper/initrd.lz || return 1
        fi

        #Install deb by apt-get install 
        if [ $BUITSTEP -le 161 ] ; then
            echo 161 >$BUILDOSSTEP
            echo 'Install qt5-qmake and qt5-default g++'
            sudo chroot $OUTPATH/squashfs-root /bin/bash -c "apt-get update"
            sudo chroot $OUTPATH/squashfs-root /bin/bash -c "apt-get -y install qt5-qmake qt5-default g++" || return 1
            echo "Install qt5-qmake and qt5-default successfull~"
            echo "Install cdosfeedback"
            installdeb "cdosfeedback"
            echo "Install cdosfeedback successfull~"
        fi

        if [ $BUITSTEP -le 190 ] ; then
            echo 190 >$BUILDOSSTEP
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd /tmp && rm -r -f *"
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd /home && rm -r -f *"
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get clean"
        fi

        umountdir || return 1

        NOWTIME=`date +%Y%m%d%H%M`
        ISONAME="$OSNAME-i386-$NOWTIME"
        ISOFILENAME="$ISONAME.iso"
        if [ $BUITSTEP -le 200 ] ; then
            echo 200 >$BUILDOSSTEP
            if [ ! -d $OUTPATH/squashfs-root/usr/share/$OSNAME ] ; then
                mkdir -p $OUTPATH/squashfs-root/usr/share$OSNAME/
            fi
            if [ $ISFROMSRC -eq 1 ] ; then
                echo source $NOWTIME | sudo tee $OUTPATH/squashfs-root/usr/share/$OSNAME/buildtime
            else
                echo normal $NOWTIME | sudo tee $OUTPATH/squashfs-root/usr/share/$OSNAME/buildtime
            fi
            mkiso $ISOFILENAME || return 1
        fi
        echo Finish building $OSFULLNAME.

        if [ $BUITSTEP -le 230 ] ; then
            echo 230 >$BUILDOSSTEP
            if [ $IS4DEBUG -eq 1 ] ; then
                ISODEBUGFILENAME="$ISONAME-debug.iso"
                mkiso_debug $ISODEBUGFILENAME $OUTPATH $APPPATH || return 1
                echo Finish building $OSFULLNAME DEBUG.
            fi
        fi

        if [ $BUITSTEP -le 240 ] ; then
            echo 240 >$BUILDOSSTEP
            if [ $IS4OEM -eq 1 ] ; then
                ISODEBUGFILENAME="$ISONAME-oem.iso"
                mkiso_oem $ISODEBUGFILENAME $OUTPATH $APPPATH || return 1
                echo Finish building $OSFULLNAME OEM.
            fi
        fi

        if [ $BUITSTEP -le 250 ] ; then
            echo 250 >$BUILDOSSTEP
            if [ $IS4TEST -eq 1 ] ; then
                #wangyu: Build iso version for test group
                echo "Start building test version..."
                sudo sed -i 's/^managed=false/managed=true/g' $OUTPATH/squashfs-root/etc/NetworkManager/NetworkManager.conf
                echo "End of reconfig /etc/NetworkManager/NetworkManager.conf file..."

                sudo cp $OUT/$PREAPP/fileForTest/rc.local $OUTPATH/squashfs-root/etc/
                echo "End of reconfig /etc/rc.local file..."

		sudo mkdir $OUTPATH/squashfs-root/tmp/fileForTest
                sudo cp -r $OUT/$PREAPP/fileForTest/*/* $OUTPATH/squashfs-root/tmp/fileForTest
                sudo chroot $OUTPATH/squashfs-root /bin/bash -c "cd tmp/fileForTest && dpkg -i -E *.deb" || return 1
		sudo rm -rf $OUTPATH/squashfs-root/tmp/*

            fi
        fi

        if [ $BUITSTEP -le 255 ] ; then
            echo 255 >$BUILDOSSTEP
            if [ $IS4TEST -eq 1 ] ; then
                ISOTESTFILENAME="$ISONAME-test.iso"
                mkiso $ISOTESTFILENAME || return 1
            fi
        fi

        echo ======
        echo Tips: You can enter runiso command to run the iso generated.
        echo ======
        echo If you want to build $OSFULLNAME again, you can enter mos 0
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function getprepkg ()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -e $OUT ] ; then
            mkdir $OUT
        fi
        cd $(gettop)
        sh $T/build/core/getprepackage.sh $OUT $OUT/$PREAPP $RAWSQUASHFSADDRESS $RAWPREAPPADDRESS || return 1
        addrepository $OUT/$PREAPP/gir1.2-gtop-2.0_2.28.4-3_i386.deb || return 1
        addrepository $OUT/$PREAPP/libfcitx-qt5-0_0.1.1-2_i386.deb || return 1
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function mountdir()
{
    if [ -e $OUT/out/squashfs-root/proc/mounts ] ; then
        sudo umount $OUT/out/squashfs-root/sys
        sudo umount $OUT/out/squashfs-root/dev/pts
        sudo umount $OUT/out/squashfs-root/dev
        sudo umount $OUT/out/squashfs-root/proc
    fi
    sudo mount -t devtmpf -o bind /dev $OUT/out/squashfs-root/dev || return 1
    sudo mount -t proc proc $OUT/out/squashfs-root/proc || return 1
    sudo mount none -t devpts $OUT/out/squashfs-root/dev/pts || return 1
    sudo mount none -t sysfs $OUT/out/squashfs-root/sys || return 1
}

function umountdir()
{
    RETVALUE=0
    sudo umount $OUT/out/squashfs-root/sys
    if [[ "$?" -ne "0" && "$?" -ne "1" ]] ; then
	$RETVALUE=2
    fi
    sudo umount $OUT/out/squashfs-root/dev/pts
    if [[ "$?" -ne "0" && "$?" -ne "1" ]] ; then
        $RETVALUE=2
    fi
    sudo umount $OUT/out/squashfs-root/dev
    if [[ "$?" -ne "0" && "$?" -ne "1" ]] ; then
        $RETVALUE=2
    fi
    sudo umount $OUT/out/squashfs-root/proc
    if [[ "$?" -ne "0" && "$?" -ne "1" ]] ; then
        $RETVALUE=2
    fi
    if [ -e $OUT/out/squashfs-root/repository ] ; then
        sudo umount $OUT/out/squashfs-root/repository
        if [[ "$?" -ne "0" && "$?" -ne "1" ]] ; then
            $RETVALUE=2
        fi
    fi
    return $RETVALUE
}

function cmove()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -f debian/rules ] ; then
            echo ERROR: No file debian/rules founded. Maybe this is not a debian package source dir.
            return 1
        fi
        isclean=1
        if [ $# -ge 1 ] ; then
            for i in "$@"
            do
    	    if [[ "$i" == "--built" ]] ; then
                    isclean=0
                fi
            done 
        fi
        dir=$(basename $PWD)
        maindir=$(basename $(dirname $PWD))
        if [ ! -d $OUT/$APPOUT/$maindir/$dir ] ; then
            mkdir -p $OUT/$APPOUT/$maindir/$dir || return 1
        fi
        for file in `ls ../ | sort`
        do
            if [ -f ../$file ] ; then
                if [ $isclean -eq 0 ] ; then
                    mv -f ../$file $OUT/$APPOUT/$maindir/$dir/ || return 1
                else
                    rm -f ../$file || return 1
                fi
            fi
        done 
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function cclean()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    echo Warning: These dirs or files in workout/ follow will be remove:

    CONDITION="N"
    dirclean=out
    if [ $# -ge 1 ] ; then
        for i in "$@"
        do
            if [[ "$i" == "-Y" || "$i" == "-y" ]] ; then
                CONDITION="Y"
	    elif [[ "$i" == "out" ]] ; then
                dirclean="out"
	    elif [[ "$i" == "app" ]] ; then
                dirclean="$APPOUT $REPODIRNAME"
	    elif [[ "$i" == "all" ]] ; then
                dirclean="out $APPOUT $REPODIRNAME"
	    else
                echo Error: unknown param $i
	        echo -y: You can ensure remove these above dirs or files -Y/-y
                echo out: You can remove only out dir
                echo app: You can remove $APPOUT $REPODIRNAME dir
                echo all: You can remove out $APPOUT $REPODIRNAME dir
                return
	    fi
        done 
    fi
    if [ $CONDITION == "N" ] ; then
        echo $OUT/ $dirclean
        read -p "Are you sure to remove these above dirs or files  Y/N:" answer
        CONDITION="$answer"
    fi

    if [[ "$CONDITION" == "Y" || "$CONDITION" == "y" ]] ; then
        echo Removing start...
        echo Umounting dir...
        umountdir 2>/dev/null
        mount | grep $OUT/out/squashfs-root
	if [ "$?" -eq "0" -o -e $OUT/out/squashfs-root/proc/mounts ] ; then
            echo "The device can not be umounted now... Please restart the computer and try it again!"
            echo move squashfs-root/dev+proc+sys to another tmpdir
            todeldir="bin boot etc home lib media mnt opt root run sbin selinux src tmp usr var"
            for dir in $todeldir
            do
                if [ -e $OUT/out/squashfs-root/$dir ] ; then
                    echo Deleting $OUT/out/squashfs-root/$dir ...
                    sudo rm -rf $OUT/out/squashfs-root/$dir
                fi
            done
            sudo rm -rf $OUT/out/$OSNAME
            cd $OUT/
            mv out out_$(date +%Y%m%d%H%M)

            #sudo fuser -k $OUT/out/squashfs-root
            #umountdir 2>/dev/null
            #mount | grep $OUT/out/squashfs-root
            #if [ "$?" -ne "0" ] ; then
            #    echo "The device can not be umounted now... Please restart the computer and try it again!"
            #    return 1
            #fi
	fi
        for dir in $dirclean
        do
            if [  -e $OUT/$dir ] ; then
                echo Deleting $OUT/$dir ...
                sudo rm -rf $OUT/$dir
            fi
        done
        echo Finished cleaning dir.
    else
        echo Removing is cancelled.
    fi
}

function ccleanout()
{
    cclean out
}

function addrepository()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -e $REPOSITORY/debian/conf ] ; then
            mkdir -p $REPOSITORY/debian/conf
        fi
        if [ ! -f $REPOSITORY/debian/conf/distributions ] ; then
            echo "Origin: Debian
Label: Debian
Codename: iceblue
Architectures: i386
Components: main" > $REPOSITORY/debian/conf/distributions
        fi
        reprepro -b $REPOSITORY/debian remove iceblue `dpkg -f $1 Package`
        reprepro -b $REPOSITORY/debian includedeb iceblue $1 || return 1
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function listappinrep()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -e $REPOSITORY/debian/conf ] ; then
            mkdir -p $REPOSITORY/debian/conf
        fi
        if [ ! -f $REPOSITORY/debian/conf/distributions ] ; then
            echo "Origin: Debian
Label: Debian
Codename: iceblue
Architectures: i386
Components: main" > $REPOSITORY/debian/conf/distributions
        fi
        reprepro -b $REPOSITORY/debian list iceblue
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    
}

function uninstallmintdeb()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -e $OUT/out/squashfs-root ] ; then
            echo Error: No squashfs-root dir exist. Have you executed mos or uniso once?
            return 1
        fi
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --purge ubuntu-system-adjustments mint-mdm-themes mint-local-repository mint-meta-codecs mint-flashplugin mint-flashplugin-11 mint-meta-cinnamon mint-meta-core mint-search-addon mint-stylish-addon mintdrivers mint-artwork-cinnamon mintsources mintbackup mintstick mintwifi mint-artwork-gnome mint-artwork-common mint-backgrounds-olivia mintsystem mintwelcome mintinstall mintinstall-icons mintnanny mintupdate mintupload mint-info-cinnamon mint-common mint-mirrors mint-translations"
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --force-all --purge mint-themes mint-x-icons " || return 1
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function uninstalldebbyapt()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    if [ $# -lt 1 ] ; then
        echo Error: no debname param
        return 1
    fi
    if [ ! -e $OUT/out/squashfs-root ] ; then
        echo Error: No squashfs-root dir exist. Have you executed mos or uniso once?
        return 1
    fi
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "DEBIAN_FRONTEND=noninteractive apt-get --ignore-missing --yes --force-yes purge $@" || return 1
}

function uninstalldeb()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    if [ $# -lt 1 ] ; then
        echo Error: no debname param
        return 1
    fi
    if [ ! -e $OUT/out/squashfs-root ] ; then
        echo Error: No squashfs-root dir exist. Have you executed mos or uniso once?
        return 1
    fi
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --purge $@" || return 1
}

function installdebonline()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    if [ $# -lt 1 ] ; then
        echo Error: no debname param
        return 1
    fi
    if [ ! -e $OUT/out/squashfs-root ] ; then
        echo Error: No squashfs-root dir exist. Have you executed mos or uniso once?
        return 1
    fi
    deblist=""
    debnum=`echo $@ | wc -w`
    if [ $debnum -gt 1 ] ; then
        for name in $@
        do
            while read line
            do
                if [ "$name" == "$line" ] ; then
                    continue 2
                fi
            done < $T/build/core/ignorepackage
            deblist=`echo $deblist $name`
            echo $deblist
        done
    else
        deblist="$@"
    fi
    echo These deb package $deblist will be installed in $OUT/out/squashfs-root
    mountdir || return 1

    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get update" || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get install -y --force-yes --reinstall $deblist" || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get clean" || return 1
    echo `echo $deblist | wc -w` package\(s\) has been installed.

    umountdir || return 1
}

function installdebtolocal()
{
    installdeb --root / $*
}

function installdeb()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    rootdir=$OUT/out/squashfs-root
    if [ $# -gt 2 ] ; then
        if [ "$1" == "--root" ] ; then
            if [ "$2" == "/" ] ; then
                rootdir=
            else
                rootdir=$2
            fi
            shift 2
        fi
    fi
    if [ $# -lt 1 ] ; then
        echo Error: no debname param
        return 1
    fi
    if [ ! -e $rootdir/ ] ; then
        echo Error: No squashfs-root dir exist. Have you executed mos or uniso once?
        return 1
    fi
    deblist=""
    debnum=`echo $@ | wc -w`
    if [ $debnum -gt 1 ] ; then
        for name in $@
        do
            while read line
            do
                if [ "$name" == "$line" ] ; then
                    continue 2
                fi
            done < $T/build/core/ignorepackage
            deblist=`echo $deblist $name`
        done
    else
        deblist="$@"
    fi
    echo These deb package $deblist will be installed in $rootdir/
    localrepo=$rootdir/repository
    if [ -e $localrepo ] ; then
        sudo umount $localrepo
    else
        sudo mkdir $localrepo
    fi
    sudo mount --bind $REPOSITORY $localrepo
    if [ "$rootdir/" == "/" ] ; then
        mountdir || return 1
    fi

    mkdir -p $rootdir/tmp/apt/root/
    mkdir -p $rootdir/tmp/apt/root/state
    mkdir -p $rootdir/tmp/apt/root/cache
    mkdir -p $rootdir/tmp/apt/root/etc
    mkdir -p $rootdir/tmp/apt/root/etc/preferences.d
    mkdir -p $rootdir/tmp/apt/root/var/log/apt/
    echo "deb file:///repository/debian iceblue main" > $rootdir/tmp/apt/root/etc/sources.list
    sudo chroot $rootdir/ /bin/bash -c "sudo apt-get update -o Dir=/tmp/apt/root/ -o Dir::State=state -o Dir::Cache=cache -o Dir::Etc=etc -o Dir::Etc::sourcelist=sources.list -o APT::Get::List-Cleanup=0" || return 1
    sudo chroot $rootdir/ /bin/bash -c "sudo apt-get install -y --force-yes --reinstall -o Dir=/tmp/apt/root/ -o Dir::State=state -o Dir::Cache=cache -o Dir::Etc=etc -o Dir::Etc::sourcelist=sources.list -o APT::Get::List-Cleanup=0 $deblist" || return 1
    echo `echo $deblist | wc -w` package\(s\) has been installed.
    sudo rm -rf $rootdir/tmp/apt

    sudo umount $localrepo
    sudo rmdir $localrepo
    if [ "$rootdir/" == "/" ] ; then
        umountdir
    fi
}

function installdeball()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    ISONLINE=0
    for i in "$@"
    do
        if [ "$i" == "--online" ] ; then
            ISONLINE=1
        fi
    done
    deblist=""
    for line in `listappinrep | cut -f 2 -d ' ' | sort`
    do
       deblist=`echo $deblist $line` 
    done
    if [ $ISONLINE -eq 0 ] ; then
        installdeb $deblist || return 1
    else
        installdebonline $deblist || return 1
    fi
}

function runiso()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    echo
    i=0
    for file in `ls $OUT/ | grep iso | sort`
    do
        echo -    $i : $file
        ((i++))
    done 
    echo You can choose one iso as above to run by kvm.
    read -p "Enter number:" no
    i=0
    for file in `ls $OUT/ | grep iso | sort`
    do
        if [ "$i" == "$no" ] ; then
            echo ======
            echo Tips: After kvm running, you can press any key to continue. 
            echo ======
            echo command: kvm -m 512 -cdrom ${OUT}/$file -boot order=d
            kvm -m 768 -cdrom ${OUT}/$file -boot order=d &
            break
        fi
        ((i++))
    done 
}

function flashiso()
{
    T=$(gettop)
    if [ ! "$T" ] ; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
    echo

    command -v usb-creator-gtk > /dev/null
    if [ ! $? == 0 ] ; then
        echo Error: usb-creator-gtk is not installed. You can install it by enter the follow command.
        echo sudo apt-get install usb-creator-gtk
        return 1
    fi

    creator_version=`dpkg -s usb-creator-gtk | grep Version | cut -d ' ' -f 2`
    if [ $creator_version \< "0.2.47.2" ] ; then
        if [ $# -eq 0 ] || [ ! $1 == "-f" ] ; then
            echo Error: the version of usb-creator-gtk is less than 0.2.47.2, so maybe you will get core dump error when executing.
            echo You can ignore this check with -f param.
            echo Or you can update it now with the following command.
            echo sudo apt-get install usb-creator-gtk
            return 1
        fi
    fi

    i=0
    for file in `ls $OUT/ | grep iso | sort`
    do
        echo -    $i : $file
        ((i++))
    done
    echo You can choose one iso as above to flash by usb-creator-gtk.
    read -p "Enter number:" no
    i=0
    for file in `ls $OUT/ | grep iso | sort`
    do
        if [ "$i" == "$no" ] ; then
            echo ======
            echo command: usb-creator-gtk -i ${OUT}/$file -n
            usb-creator-gtk -i ${OUT}/$file -n
            break
        fi
        ((i++))
    done
}

function pid()
{
   local EXE="$1"
   if [ "$EXE" ] ; then
       local PID=`adb shell ps | fgrep $1 | sed -e 's/[^ ]* *\([0-9]*\).*/\1/'`
       echo "$PID"
   else
       echo "usage: pid name"
   fi
}

case `uname -s` in
    Darwin)
        function sgrep()
        {
            find -E . -name .repo -prune -o -name .git -prune -o  -type f -iregex '.*\.(c|h|cpp|S|java|xml|sh|mk)' -print0 | xargs -0 grep --color -n "$@"
        }

        ;;
    *)
        function sgrep()
        {
            find . -name .repo -prune -o -name .git -prune -o  -type f -iregex '.*\.\(c\|h\|cpp\|S\|java\|xml\|sh\|mk\)' -print0 | xargs -0 grep --color -n "$@"
        }
        ;;
esac

function jgrep()
{
    find . -name .repo -prune -o -name .git -prune -o  -type f -name "*\.java" -print0 | xargs -0 grep --color -n "$@"
}

function psgrep()
{
    find . -name .repo -prune -o -name .git -prune -o  -type f \( -name '*.py' -o -name '*.js' \) -print0 | xargs -0 grep --color -n "$@"
}

function cgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.h' \) -print0 | xargs -0 grep --color -n "$@"
}


case `uname -s` in
    Darwin)
        function mgrep()
        {
            find -E . -name .repo -prune -o -name .git -prune -o  -type f -iregex '.*/(Makefile|Makefile\..*|.*\.make|.*\.mak|.*\.mk)' -print0 | xargs -0 grep --color -n "$@"
        }

        function treegrep()
        {
            find -E . -name .repo -prune -o -name .git -prune -o -type f -iregex '.*\.(c|h|cpp|S|java|xml)' -print0 | xargs -0 grep --color -n -i "$@"
        }

        ;;
    *)
        function mgrep()
        {
            find . -name .repo -prune -o -name .git -prune -o -regextype posix-egrep -iregex '(.*\/Makefile|.*\/Makefile\..*|.*\.make|.*\.mak|.*\.mk)' -type f -print0 | xargs -0 grep --color -n "$@"
        }

        function treegrep()
        {
            find . -name .repo -prune -o -name .git -prune -o -regextype posix-egrep -iregex '.*\.(c|h|cpp|S|java|xml)' -type f -print0 | xargs -0 grep --color -n -i "$@"
        }

        ;;
esac


function godir () {
    if [[ -z "$1" ]]; then
        echo "Usage: godir <regex>"
        return 1
    fi
    T=$(gettop)
    if [[ ! -f $T/filelist ]]; then
        echo -n "Creating index..."
        (cd $T; find . -wholename ./out -prune -o -wholename ./.repo -prune -o -type f > filelist)
        echo " Done"
        echo ""
    fi
    local lines
    lines=($(\grep "$1" $T/filelist | sed -e 's/\/[^/]*$//' | sort | uniq))
    if [[ ${#lines[@]} = 0 ]]; then
        echo "Not found"
        return 1
    fi
    local pathname
    local choice
    if [[ ${#lines[@]} > 1 ]]; then
        while [[ -z "$pathname" ]]; do
            local index=1
            local line
            for line in ${lines[@]}; do
                printf "%6s %s\n" "[$index]" $line
                index=$(($index + 1))
            done
            echo
            echo -n "Select one: "
            unset choice
            read choice
            if [[ $choice -gt ${#lines[@]} || $choice -lt 1 ]]; then
                echo "Invalid choice"
                continue
            fi
            pathname=${lines[$(($choice-1))]}
        done
    else
        pathname=${lines[0]}
    fi
    cd $T/$pathname
}

if [ "x$SHELL" != "x/bin/bash" ]; then
    case `ps -o command -p $$` in
        *bash*)
            ;;
        *)
            echo "WARNING: Only bash is supported, use of other shell would lead to erroneous results"
            ;;
    esac
fi
setenv
addcompletions
