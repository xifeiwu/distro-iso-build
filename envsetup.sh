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
- mcos:      Build all and generate iso.
- mall:      Build all packages in cos and desktop dir, and then move these .deb .tar.gz .dsc .changes file to workout/app dir.
- uniso:     Export iso file to workout/out dir.
- mkiso:     Generate iso file into workout dir from workout/out file.
- cgrep:     Greps on all local C/C++ files.
- psgrep:    Greps on all local py js files.
- jgrep:     Greps on all local Java files.
- godir:     Go to the directory containing a file.
- hcos:      show more help.

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

function hcos()
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

    export COSARCH=i386
    export BASE_RELEASE=raring
    export BASE_RELEASE_WEB=http://192.168.160.169/cos3/ubuntu/

    export OUT=$T/workout
    export ROOTFS=$OUT/out/squashfs-root
    export APPOUT=debsaved
    export PREAPP=preapp
    export REPOSITORY=$OUT/repository
    export BUILDCOSSTEP=$OUT/out/buildcosstep
    export BUILDALLSTEP=$REPOSITORY/buildallstep
    export RAWSQUASHFSNAME=filesystem-zhoupeng-20140108.squashfs
    export ISOPATH=$OUT/$RAWSQUASHFSNAME
    export RAWSQUASHFSADDRESS=box@192.168.162.142:/home/box/Workspace/Public/$RAWSQUASHFSNAME
    export RAWPREAPPADDRESS=box@192.168.162.142:/home/box/Workspace/Public/app/
    export KERNEL_VERSION=3.8.13
    export KERNEL_VERSION_FULL=3.8.13.13-cos-i686
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
        SRCDesktopPATH=$T/desktop
        SRCCOSPATH=$T/cos
        CURDIR=$PWD
        echo check build dependencies and conflicts of all deb package
        echo
        for dir in `ls $SRCDesktopPATH | sort`
        do
            if [ -d $SRCDesktopPATH/$dir ] ; then
                cd $SRCDesktopPATH/$dir
                echo checking dependencies of $dir
                tmpstr=`dpkg-checkbuilddeps 2>&1`
                tmpres=$?
                echo $tmpstr | awk '{gsub(/\([^\(\)]*\)/, ""); print}'
            fi
        done 
        for dir in `ls $SRCCOSPATH | sort`
        do
            if [ -d $SRCCOSPATH/$dir ] ; then
                cd $SRCCOSPATH/$dir
                echo checking $dir
                tmpstr=`dpkg-checkbuilddeps 2>&1`
                tmpres=$?
                echo $tmpstr | awk '{gsub(/\([^\(\)]*\)/, ""); print}'
            fi
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
    sudo sh $T/build/mkiso.sh $OUT/out $OUT || return 1
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
    if [ $# -gt 0 ] ; then
        if [ "$1" == "--install" ] ; then
            shift
            ISINSTALL=1
        fi
    fi
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
                echo tips: cmove: you should enter cmove command to move this files into $OUT/$APPOUT dir.
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
            return 1
        fi
        echo Info: These deb files above has been added into repository.
        if [ $ISINSTALL == 1 ] ; then
           installdeb "$DEBTOINSTALL"
        fi 
        cmove
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function mi()
{
    T=$(gettop)
    if [ "$T" ]; then
        mm --install -tc
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
    LASTSTEP=0
    if [ -e $BUILDALLSTEP ] ; then
        LASTSTEP=`cat $BUILDALLSTEP`
    fi
    for i in "$@"
    do
        if [ "$i" -ge 0 ] 2>/dev/null ; then
            LASTSTEP=$i
        fi
    done
    if [ "$T" ]; then
        if [ ! -e $REPOSITORY ] ; then
            mkdir -p $REPOSITORY
        fi
        echo Building all deb packages

        SRCDesktopPATH=$T/desktop
        SRCCOSPATH=$T/cos
        CURDIR=$PWD
        if [ $LASTSTEP == 0 ] ; then
            echo check build dependencies and conflicts of all deb package
            checkdepall | grep dpkg-checkbuilddeps
            if [ $? -eq 0 ] ; then
                echo Error: some dependencis has not been met.
                return 1
            fi
            echo Finish checking building deb packages
        fi
        echo
        step=0
        for dir in `ls $SRCDesktopPATH | sort`
        do
            if [ -d $SRCDesktopPATH/$dir ] ; then
                ((step++))
                if [ $step -lt $LASTSTEP ] ; then
                    continue
                fi
                echo $step >$BUILDALLSTEP
                cd $SRCDesktopPATH/$dir
                echo $step building $dir
                mm -tc
                if [ $? -ne 0 ] ; then
                    echo Error has happened when building $dir. Please check the log above. You can enter checkdepall to find the whole list of dependencies to require.
                    return 1
                fi
            fi
        done 
        for dir in `ls $SRCCOSPATH | sort`
        do
            if [ -d $SRCCOSPATH/$dir ] ; then
                ((step++))
                if [ $step -lt $LASTSTEP ] ; then
                    continue
                fi
                echo $step >$BUILDALLSTEP
                cd $SRCCOSPATH/$dir
                echo $step building $dir
                mm -tc
                if [ $? -ne 0 ] ; then
                    echo Error has happened when building $dir. Please check the log above. You can enter checkdepall to find the whole list of dependencies to require.
                    return 1
                fi
            fi
        done 
        ((step++))
        echo $step >$BUILDALLSTEP
        echo
        echo Finish building all deb packages
        echo  
        echo If you want to build all deb packages again, you can enter mall 0
        cd $CURDIR
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function mroot()
{
    if [ -d $OUT/out ] ; then
        echo ERROR:out dir has exist.
        return 1
    fi
    mkdir -p $OUT/out || return 1

    echo Begin to debootstrap...
    sudo debootstrap --arch=${COSARCH} --no-check-gpg ${BASE_RELEASE} $ROOTFS ${BASE_RELEASE_WEB}  || return 1
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
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get update"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get install --yes dbus" # ???
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dbus-uuidgen > /var/lib/dbus/machine-id"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg-divert --local --rename --add /sbin/initctl"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "ln -s /bin/true /sbin/initctl"
    sudo rm -f $T/build/core/srcbuild/fail_stage1
    sudo rm -f $T/build/core/srcbuild/fail_stage2
    sudo rm -f $T/build/core/srcbuild/fail_stage3
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -f install"

    # stage1
    echo "------------------------------stage1------------------------------------------"
    while read list
    do
        pkgsname=`echo $list | awk '{print $1}'`
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get install --yes --allow-unauthenticated ${pkgsname}"
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
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get install --yes --allow-unauthenticated ${pkgsname}"
        if [ $? -ne 0 ];then
                echo $pkgsname >>  $T/build/core/srcbuild/fail_stage2
        fi
    done <  $T/build/core/srcbuild/fail_stage1

    # stage3 force install
    echo "------------------------------stage3------------------------------------------"
    while read pkgsname
    do
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get install --yes --force-yes --allow-unauthenticated ${pkgsname}"
        if [ $? -ne 0 ];then
                echo $pkgsname >>  $T/build/core/srcbuild/fail_stage3
        fi
    done <  $T/build/core/srcbuild/fail_stage2

    # clean unnecessary packages
    echo "-----------apt-get autoremove, clean unnecessary dependency packages---------"
    # autoremove is used to remove packages that were automatically installed to satisfy dependencies for other packages and are now no longer needed.
    sudo chroot chroot /bin/bash -c "apt-get autoremove"
    sudo chroot chroot /bin/bash -c "apt-get clean"

    #clean squashfs
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /etc/apt/sources.list"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /etc/apt/preferences"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /etc/apt/apt.conf.d/99myown"

    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /var/lib/dbus/machine-id"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /sbin/initctl"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg-divert --rename --remove /sbin/initctl"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get clean"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm -rf /tmp/*"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "rm /etc/resolv.conf"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "umount -lf /proc"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "umount -lf /sys"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "umount -lf /dev/pts"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "exit"
    sudo umount -l $OUT/out/squashfs-root/dev
}

function mcos()
{
    ISONLINE=0
    BUITSTEP=0
    IS4LENOVO=0
    IS4S3G=0
    IS4TEST=0
    if [ -e $BUILDCOSSTEP ] ; then
        BUITSTEP=`cat $BUILDCOSSTEP`
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
            touch $BUILDCOSSTEP 2>/dev/null
            if [ $? -ne 0 ] ; then
                Group=`groups $USER | cut -d ' ' -f 1`
                sudo chown $Group.$USER $OUT/out
            fi
        fi

        echo Building COS Desktop ...
        if [ $BUITSTEP -le 10 ] ; then
            echo 10 >$BUILDCOSSTEP
            getprepkg || return 1
        fi
        if [ $BUITSTEP -le 20 ] ; then
            echo 20 >$BUILDCOSSTEP
            checktools || return 1
            mall || return 1
        fi
        if [ $BUITSTEP -le 30 ] ; then
            echo 30 >$BUILDCOSSTEP
            uniso || return 1
        fi

	if [ $BUITSTEP -le 31 ] ; then
            echo 31 >$BUILDCOSSTEP
            sudo cp $T/build/release/tmpfiles/mdm/mdm.conf $OUTPATH/squashfs-root/etc/mdm/
            uninstalldeb "account-plugin-facebook account-plugin-flickr account-plugin-google account-plugin-twitter alacarte appmenu-gtk appmenu-gtk3 appmenu-qt appmenu-qt5 apport apport-symptoms bamfdaemon banshee-extension-soundmenu bison build-essential cdparanoia cdrdao compiz compiz-core compiz-gnome compiz-plugins-default curl dconf-tools debhelper dh-apparmor docbook-xsl dpkg-dev firefox-globalmenu flex freepats friends-facebook friends-twitter g++ g++-4.7 gir1.2-panelapplet-4.0 gir1.2-rb-3.0 gir1.2-unity-5.0 gnome-applets gnome-applets-data gnome-control-center gnome-control-center-data gnome-control-center-signon gnome-control-center-unity gnome-media gnome-session gnome-session-fallback gnome-user-guide gromit gstreamer0.10-gnomevfs html2text hud humanity-icon-theme icoutils indicator-applet-complete indicator-appmenu indicator-datetime indicator-messages indicator-power indicator-printers indicator-session indicator-sound k3b k3b-data kate-data katepart kbuild kde-runtime kde-runtime-data kde-style-oxygen kde-window-manager kde-window-manager-common kdelibs-bin kdelibs5-data kdelibs5-plugins kdoctools kubuntu-debug-installer libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libattica0.4 libbamf3-1 libbison-dev libcompizconfig0 libdlrestrictions1 libencode-locale-perl libfile-listing-perl libfl-dev libflac++6 libfont-afm-perl libgnome-control-center1 libgnome-media-profiles-3.0-0 libgnomevfs2-extra libhtml-form-perl libhtml-format-perl libhtml-parser-perl libhtml-tagset-perl libhtml-tree-perl libhttp-cookies-perl libhttp-daemon-perl libhttp-date-perl libhttp-message-perl libhttp-negotiate-perl libibus-1.0-0 libio-socket-ssl-perl libk3b6 libkactivities-bin libkactivities-models1 libkactivities6 libkatepartinterfaces4 libkcddb4 libkcmutils4 libkde3support4 libkdeclarative5 libkdecorations4abi1 libkdecore5 libkdesu5 libkdeui5 libkdewebkit5 libkdnssd4 libkemoticons4 libkfile4 libkhtml5 libkidletime4 libkio5 libkjsapi4 libkjsembed4 libkmediaplayer4 libknewstuff3-4 libknotifyconfig4 libkntlm4 libkparts4 libkpty4 libkrosscore4 libktexteditor4 libkwineffects1abi4 libkwinglutils1abi1 libkwinnvidiahack4 libkworkspace4abi2 libkxmlrpcclient4 liblwp-mediatypes-perl liblwp-protocol-https-perl libmail-sendmail-perl libmusicbrainz5-0 libmysqlclient18 libnepomuk4 libnepomukcore4abi1 libnepomukquery4a libnepomukutils4 libnet-http-perl libnet-ssleay-perl libntrack-qt4-1 libntrack0 libnux-4.0-0 libplasma3 libpolkit-qt-1-1 libpoppler-qt4-4 libqapt2 libqapt2-runtime libqca2 libqt4-qt3support libqt4-sql-mysql librhythmbox-core6 libsolid4 libsoprano4 libstdc++6-4.7-dev libstreamanalyzer0 libstreams0 libsys-hostname-long-perl libthreadweaver4 libunity-core-6.0-5 libunity-misc4 libunity-webapps0 libvirtodbc0 libwww-perl libwww-robotrules-perl libxcb-damage0 libxml2-utils m4 module-assistant mysql-common nautilus nepomuk-core nepomuk-core-data notification-daemon ntrack-module-libnl-0 odbcinst odbcinst1debian2 openjdk-6-jre openjdk-6-jre-headless openjdk-6-jre-lib oxygen-icon-theme plasma-scriptengine-javascript po-debconf python-zeitgeist python3-apport python3-dbus.mainloop.qt python3-problem-report python3-pyqt4 python3-sip qapt-batch rhythmbox rhythmbox-data rhythmbox-mozilla rhythmbox-plugin-cdrecorder rhythmbox-plugin-zeitgeist rhythmbox-plugins rhythmbox-ubuntuone shared-desktop-ontologies soprano-daemon thunderbird-globalmenu ubiquity-frontend-kde ubuntu-release-upgrader-core unity unity-asset-pool unity-common unity-lens-applications unity-lens-files unity-lens-friends unity-lens-music unity-lens-photos unity-lens-shopping unity-lens-video unity-scope-gdrive unity-scope-musicstores unity-scope-video-remote unity-services unity-webapps-service update-manager-core vcdimager virtualbox-guest-source virtuoso-minimal virtuoso-opensource-6.1-bin virtuoso-opensource-6.1-common xchat-indicator xul-ext-ubufox zeitgeist zeitgeist-core zeitgeist-datahub rhythmbox-plugin-cdrecorder" || return 1
        fi

        mountdir || return 1

        if [ $BUITSTEP -le 40 ] ; then
            echo 40 >$BUILDCOSSTEP
            intkernel || return 1
        fi

        if [ $BUITSTEP -le 41 ] ; then
            echo 41 >$BUILDCOSSTEP
            if [ $IS4LENOVO -eq 1 ] ; then
                intnvidiadriver || return 1
            fi
        fi

        if [ $BUITSTEP -le 42 ] ; then
            echo 42 >$BUILDCOSSTEP
            if [ $IS4S3G -eq 1 ] ; then
                sudo sh $T/build/core/vendor/install_via_driver.sh $OUTPATH $APPPATH/drivers/s3g/s3g-138603.tar.bz2 $APPPATH/drivers/s3g/patches $KERNEL_VERSION_FULL || return 1
            fi
        fi

        if [ $BUITSTEP -le 43 ] ; then
            echo 43 >$BUILDCOSSTEP
            sudo sh $T/build/release/installnouveau.sh $OUTPATH $APPPATH || return 1
        fi
        
        if [ $BUITSTEP -le 44 ] ; then
            echo 44 >$BUILDCOSSTEP
            sudo sh $T/build/core/vendor/install_via_driver.sh $OUTPATH $APPPATH/drivers/s3g/s3g-138603.tar.bz2 $APPPATH/drivers/s3g/patches $KERNEL_VERSION_FULL || return 1
        fi       

        #Install popular software
        if [ $BUITSTEP -le 50 ] ; then
            echo 50 >$BUILDCOSSTEP
            sudo sh $T/build/release/installzh_CN.sh $OUTPATH $APPPATH || return 1
        fi
        if [ $BUITSTEP -le 51 ] ; then
            echo 51 >$BUILDCOSSTEP
            sudo sh $T/build/release/installfirefox.sh $OUTPATH $APPPATH || return 1
        fi
        if [ $BUITSTEP -le 52 ] ; then
            echo 52 >$BUILDCOSSTEP
            sudo sh $T/build/release/installvim.sh $OUTPATH $APPPATH || return 1
        fi

        #Install ssh and close root user with ssh authority.
        if [ $BUITSTEP -le 54 ] ; then
            echo 54 >$BUILDCOSSTEP
            sudo sh $T/build/release/installssh.sh $OUTPATH $APPPATH || return 1
        fi

        #Change some zh_CN LC_MESSAGES
        if [ $BUITSTEP -le 80 ] ; then
            echo 80 >$BUILDCOSSTEP
            sudo sh $T/build/release/change_zh_CN.sh $OUTPATH || return 1
        fi

        #Change system name in some where. This shell file also will install some software in cos source list.
        if [ $BUITSTEP -le 90 ] ; then
            echo 90 >$BUILDCOSSTEP
            sudo sh $T/build/release/ubiquity.sh $T/build/release/ $OUTPATH || return 1
        fi

        if [ $BUITSTEP -le 100 ] ; then
            echo 100 >$BUILDCOSSTEP
            sudo sh $T/build/core/set_sourcelist.sh $OUTPATH/squashfs-root || return 1
            mountdir  || return 1
            uninstallmintdeb || return 1
	    #wangyu: Debs should be removed by the information of Local Application Group
		#The cause of umount failure pacakage is "pidgin"
	    uninstalldeb "cos-meta-codecs libreoffice-base libreoffice-base-core libreoffice-calc libreoffice-emailmerge libreoffice-gnome libreoffice-gtk libreoffice-help-en-gb libreoffice-help-en-us libreoffice-help-zh-cn libreoffice-impress libreoffice-java-common libreoffice-math libreoffice-ogltrans libreoffice-presentation-minimizer libreoffice-writer mythes-en-us banshee gimp gimp-data gimp-help-common gimp-help-en eog transmission-common transmission-gtk pidgin pidgin-data pidgin-facebookchat pidgin-libnotify brasero vlc vlc-data vlc-nox vlc-plugin-notify vlc-plugin-pulse libvlccore5 libvlc5 brasero-cdrkit brasero-common libbrasero-media3-1 banshee-extension-soundmenu libbrasero-media3-1" || return 1
            umountdir || return 1
            uninstalldeb "pidgin pidgin-data pidgin-facebookchat pidgin-libnotify" || return 1
            if [ $ISONLINE == 1 ] ; then
                installdebonline "ubuntu-system-adjustments cos-mdm-themes cos-local-repository cos-flashplugin cos-flashplugin-11 cos-meta-cinnamon cos-meta-core cos-stylish-addon cosdrivers cos-artwork-cinnamon cossources cosbackup cosstick coswifi cos-artwork-gnome cos-themes cos-artwork-common cos-backgrounds-iceblue cos-x-icons cossystem coswelcome cosinstall cosinstall-icons cosnanny cosupdate cosupload cos-info-iceblue cos-common cos-mirrors cos-translations cinnamon cinnamon-common cinnamon-screensaver nemo nemo-data nemo-share cos-upgrade"  || return 1
            else
                installdeb "cinnamon cinnamon-common cinnamon-control-center cinnamon-control-center-data cinnamon-screensaver cos-artwork-cinnamon cos-artwork-common cos-artwork-gnome cos-backgrounds-iceblue cosbackup cos-common cosdrivers cos-flashplugin cos-flashplugin-11 cos-info-iceblue cosinstall cosinstall-icons cos-local-repository cos-mdm-themes cos-meta-core cos-mirrors cosnanny cossources cosstick cos-stylish-addon cossystem cos-themes cos-translations cosupdate cos-upgrade cosupload coswelcome coswifi cos-x-icons gir1.2-gtop-2.0 gnome-screenshot gnome-system-monitor libcinnamon-control-center1 libcinnamon-control-center-dev nemo nemo-data nemo-share ubuntu-system-adjustments" || return 1
            fi
            mountdir || return 1
	    sudo sed -i 's/^DefaultSession=default.desktop/DefaultSession=cinnamon.desktop/g' $OUTPATH/squashfs-root/usr/share/mdm/defaults.conf || return 1
            sudo sed -i 's/^DefaultSession=default.desktop/DefaultSession=cinnamon.desktop/g' $OUTPATH/squashfs-root/usr/share/ubuntu-system-adjustments/mdm/defaults.conf || return 1
        fi
	#wangyu: Install apps from local application group.
	if [ $BUITSTEP -le 101 ] ; then
            echo 101 >$BUILDCOSSTEP
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
            echo 110 >$BUILDCOSSTEP
            sudo sh $T/build/release/mktheme.sh $OUTPATH || return 1
        fi
        if [ $BUITSTEP -le 120 ] ; then
            echo 120 >$BUILDCOSSTEP
            sudo sh $T/build/release/change_start_menu_icons.sh $OUTPATH || return 1
        fi
        if [ $BUITSTEP -le 130 ] ; then
            echo 130 >$BUILDCOSSTEP
            sudo sh $T/build/release/change_start_menu.sh $OUTPATH || return 1
        fi

        #fix some bugs by change files directly.
        if [ $BUITSTEP -le 140 ] ; then
            echo 140 >$BUILDCOSSTEP
            sudo sh $T/build/release/set_username_for_WPS.sh $OUTPATH $OUT/$PREAPP  || return 1
            sudo sh $T/build/release/remove_update_userdir.sh $OUTPATH || return 1
            sudo sh $T/build/release/change_networking.sh $OUTPATH || return 1
        fi

        if [ $BUITSTEP -le 148 ] ; then
            echo 148 >$BUILDCOSSTEP
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "update-initramfs -u" || return 1
            sudo cp $OUT/out/squashfs-root/boot/vmlinuz-${KERNEL_VERSION_FULL} $OUT/out/mycos/casper/vmlinuz || return 1
            sudo cp $OUT/out/squashfs-root/boot/initrd.img-${KERNEL_VERSION_FULL} $OUT/out/mycos/casper/initrd.lz || return 1
        fi

        if [ $BUITSTEP -le 150 ] ; then
            echo 150 >$BUILDCOSSTEP
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


        if [ $BUITSTEP -le 190 ] ; then
            echo 190 >$BUILDCOSSTEP
            sudo chroot $OUT/out/squashfs-root /bin/bash -c "cd /tmp && rm -r *"
        fi

        umountdir || return 1

        if [ $BUITSTEP -le 200 ] ; then
            echo 200 >$BUILDCOSSTEP
            mkiso || return 1
        fi
        echo 200 >$BUILDCOSSTEP
        echo Finish building COS Desktop.
        echo ======
        echo Tips: You can enter runiso command to run the iso generated.
        echo ======
        echo If you want to build COS Desktop again, you can enter mcos 0
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
        if [ ! -e $OUT/$APPOUT/ ] ; then
            mkdir $OUT/$APPOUT
        fi
        for file in `ls ../ | sort`
        do
            if [ -f ../$file ] ; then
                mv ../$file $OUT/$APPOUT
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
    echo $OUT/out
    echo $REPOSITORY
    echo $OUT/$APPOUT

    CONDITION="N"
    if [ $# -ge 1 ] ; then
        for i in "$@"
        do
            if [[ "$i" == "-Y" || "$i" == "-y" ]] ; then
                CONDITION="Y"
	    else
	        echo Warning: You can remove these above dirs or files -Y/-y
	    fi
        done 
    else 
        read -p "Are you sure to remove these above dirs or files  Y/N:" answer
        CONDITION="$answer"
    fi
    
    if [[ "$CONDITION" == "Y" || "$CONDITION" == "y" ]] ; then
        echo Umounting dir...
        umountdir 2>/dev/null
	if [ "$?" -ne "0" ] ; then
	    echo "The device can not be umounted now... Please restart the computer and try it again!"
	    return 1
	fi	
        if [ -e $OUT/buildallstep ] ; then
            rm $OUT/buildallstep
        fi
        if [ -e $OUT/buildcosstep ] ; then
            rm $OUT/buildcosstep
        fi
        if [  -e $OUT/out ] ; then
            echo Deleting $OUT/out ...
            sudo rm -r $OUT/out
        fi
        if [  -e $REPOSITORY ] ; then
            echo Deleting $REPOSITORY ...
            rm -r $REPOSITORY
        fi
        if [  -e $OUT/$APPOUT ] ; then
            echo Deleting $OUT/$APPOUT ...
            rm -r $OUT/$APPOUT
        fi 
        if [  -e $OUT/appout ] ; then
            echo Deleting $OUT/appout ...
            rm -r $OUT/appout
        fi 
        if [  -e $OUT/appbuilt ] ; then
            echo Deleting $OUT/$appbuilt ...
            rm -r $OUT/appbuilt
        fi 
        echo Finished cleaning workout dir.
    fi
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
            echo Error: No squashfs-root dir exist. Have you executed mcos or uniso once?
            return 1
        fi
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --purge ubuntu-system-adjustments mint-mdm-themes mint-local-repository mint-meta-codecs mint-flashplugin mint-flashplugin-11 mint-meta-cinnamon mint-meta-core mint-search-addon mint-stylish-addon mintdrivers mint-artwork-cinnamon mintsources mintbackup mintstick mintwifi mint-artwork-gnome mint-artwork-common mint-backgrounds-olivia mintsystem mintwelcome mintinstall mintinstall-icons mintnanny mintupdate mintupload mint-info-cinnamon mint-common mint-mirrors mint-translations mint-info-xfce"
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --force-all --purge mint-themes mint-x-icons " || return 1
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
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
        echo Error: No squashfs-root dir exist. Have you executed mcos or uniso once?
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
        echo Error: No squashfs-root dir exist. Have you executed mcos or uniso once?
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

    sudo chroot $OUT/out/squashfs-root /bin/bash -c 'sudo apt-get update -o Dir::Etc::sourcelist="sources.list.d/cos-repository.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"' || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get install -y --force-yes --reinstall -o Dir::Etc::sourcelist=\"sources.list.d/cos-dev-repository.list\" $deblist" || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get clean" || return 1
    echo `echo $deblist | wc -w` package\(s\) has been installed.

    umountdir || return 1
}

function installdeb()
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
        echo Error: No squashfs-root dir exist. Have you executed mcos or uniso once?
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
    echo These deb package $deblist will be installed in $OUT/out/squashfs-root
    if [ -e $OUT/out/squashfs-root/repository ] ; then
        sudo umount $OUT/out/squashfs-root/repository
    else
        sudo mkdir $OUT/out/squashfs-root/repository
    fi
    sudo mount --bind $REPOSITORY $OUT/out/squashfs-root/repository
    mountdir || return 1

    echo "deb file:///repository/debian iceblue main" > /tmp/cos-dev-repository.list
    sudo mv /tmp/cos-dev-repository.list $OUT/out/squashfs-root/etc/apt/sources.list.d/
    sudo chroot $OUT/out/squashfs-root /bin/bash -c 'sudo apt-get update -o Dir::Etc::sourcelist="sources.list.d/cos-dev-repository.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"' || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get install -y --force-yes --reinstall -o Dir::Etc::sourcelist=\"sources.list.d/cos-dev-repository.list\" $deblist" || return 1
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get clean" || return 1
    echo `echo $deblist | wc -w` package\(s\) has been installed.

    sudo rm $OUT/out/squashfs-root/etc/apt/sources.list.d/cos-dev-repository.list

    umountdir
    sudo umount $OUT/out/squashfs-root/repository
    sudo rmdir $OUT/out/squashfs-root/repository
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
            kvm -m 512 -cdrom ${OUT}/$file -boot order=d &
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
