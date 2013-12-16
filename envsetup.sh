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
        return
    fi

    cat $T/docs/repo_help.txt | more
}

function repo()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return
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
        return
    fi

    . $T/build/set_version.sh

    export OUT=$T/workout
    export APPOUT=debsaved
    export PREAPP=preapp
    export REPOSITORY=$OUT/repository
    export BUILDCOSSTEP=$OUT/out/buildcosstep
    export BUILDALLSTEP=$REPOSITORY/buildallstep
    export RAWISONAME=cos_orig_v0.9_nvi+s3g.iso2.iso
    export ISOPATH=$OUT/$RAWISONAME
    export RAWISOADDRESS=box@192.168.162.142:/home/box/Workspace/Public/$RAWISONAME
    export RAWPREAPPADDRESS=box@192.168.162.142:/home/box/Workspace/Public/app/
}

function addcompletions()
{
    local T dir f

    # Keep us from trying to run in something that isn't bash.
    if [ -z "${BASH_VERSION}" ]; then
        return
    fi

    # Keep us from trying to run in bash that's too old.
    if [ ${BASH_VERSINFO[0]} -lt 3 ]; then
        return
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
    checktools
    checkdepall
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
    if [ "$T" ]; then
        if [ ! -e $OUT/out ] ; then
            mkdir -p $OUT/out
        fi
        checktools || return 1
        sudo sh $T/build/uniso.sh $ISOPATH $OUT/out
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function mkiso()
{
    T=$(gettop)
    if [ "$T" ]; then
        sudo sh $T/build/mkiso.sh $OUT/out $OUT
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
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

function mcos()
{
    ISONLINE=0
    BUITSTEP=0
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
            getprepkg || return
        fi
        if [ $BUITSTEP -le 20 ] ; then
            echo 20 >$BUILDCOSSTEP
            checktools || return
            mall || return
        fi
        if [ $BUITSTEP -le 30 ] ; then
            echo 30 >$BUILDCOSSTEP
            uniso || return
        fi

        mountdir

        if [ $BUITSTEP -le 40 ] ; then
            echo 40 >$BUILDCOSSTEP
            sudo sh $T/build/release/installzh_CN.sh $OUTPATH $APPPATH || return
        fi

        #Install popular software
        if [ $BUITSTEP -le 50 ] ; then
            echo 50 >$BUILDCOSSTEP
            sudo sh $T/build/release/installwps.sh $OUTPATH $APPPATH || return
        fi
        if [ $BUITSTEP -le 51 ] ; then
            echo 51 >$BUILDCOSSTEP
            sudo sh $T/build/release/installfirefox.sh $OUTPATH $APPPATH || return
#            sudo sh $T/build/release/installchrome.sh $OUTPATH $APPPATH || return
        fi
        if [ $BUITSTEP -le 52 ] ; then
            echo 52 >$BUILDCOSSTEP
            sudo sh $T/build/release/installvim.sh $OUTPATH $APPPATH || return
        fi
        if [ $BUITSTEP -le 53 ] ; then
            echo 53 >$BUILDCOSSTEP
#            sudo sh $T/build/release/installwineqq.sh $OUTPATH $APPPATH || return
        fi

        #Install ssh and close root user with ssh authority.
        if [ $BUITSTEP -le 54 ] ; then
            echo 54 >$BUILDCOSSTEP
            sudo sh $T/build/release/installssh.sh $OUTPATH $APPPATH || return
        fi

        #Install Self software
        if [ $BUITSTEP -le 55 ] ; then
            echo 55 >$BUILDCOSSTEP
#            sudo sh $T/build/release/installrdpdesk.sh $OUTPATH $APPPATH || return
        fi
        if [ $BUITSTEP -le 56 ] ; then
            echo 56 >$BUILDCOSSTEP
#            sudo sh $T/build/release/installqtadb.sh $OUTPATH $APPPATH || return
        fi

        #Change iso files
        if [ $BUITSTEP -le 60 ] ; then
            echo 60 >$BUILDCOSSTEP
            sudo sh $T/build/release/change_iso_files.sh $OUTPATH || return
        fi
        if [ $BUITSTEP -le 70 ] ; then
            echo 70 >$BUILDCOSSTEP
            sudo sh $T/build/release/remove_wubi.sh $OUTPATH || return
        fi

        #Change some zh_CN LC_MESSAGES
        if [ $BUITSTEP -le 80 ] ; then
            echo 80 >$BUILDCOSSTEP
            sudo sh $T/build/release/change_zh_CN.sh $OUTPATH || return
        fi

        #Change system name in some where. This shell file also will install some software in cos source list.
        if [ $BUITSTEP -le 90 ] ; then
            echo 90 >$BUILDCOSSTEP
            sudo sh $T/build/release/ubiquity.sh $T/build/release/ $OUTPATH || return
        fi

        if [ $BUITSTEP -le 100 ] ; then
            echo 100 >$BUILDCOSSTEP
            sudo sh $T/build/core/set_sourcelist.sh $OUTPATH/squashfs-root || return
            uninstallmintdeb || return
	    #wangyu: Debs should be removed by the information of Local Application Group
	    uninstalldeb "cos-meta-codecs libreoffice-base libreoffice-base-core libreoffice-calc libreoffice-emailmerge libreoffice-gnome libreoffice-gtk libreoffice-help-en-gb libreoffice-help-en-us libreoffice-help-zh-cn libreoffice-impress libreoffice-java-common libreoffice-math libreoffice-ogltrans libreoffice-presentation-minimizer libreoffice-writer mythes-en-us banshee gimp gimp-data gimp-help-common gimp-help-en eog transmission-common transmission-gtk pidgin pidgin-data pidgin-facebookchat pidgin-libnotify brasero vlc vlc-data vlc-nox vlc-plugin-notify vlc-plugin-pulse libvlccore5 libvlc5" || return
            if [ $ISONLINE == 1 ] ; then
                installdebonline "ubuntu-system-adjustments cos-mdm-themes cos-local-repository cos-flashplugin cos-flashplugin-11 cos-meta-cinnamon cos-meta-core cos-stylish-addon cosdrivers cos-artwork-cinnamon cossources cosbackup cosstick coswifi cos-artwork-gnome cos-themes cos-artwork-common cos-backgrounds-iceblue cos-x-icons cossystem coswelcome cosinstall cosinstall-icons cosnanny cosupdate cosupload cos-info-iceblue cos-common cos-mirrors cos-translations cinnamon cinnamon-common cinnamon-screensaver nemo nemo-data nemo-share cos-upgrade" 
            else
                installdeb "cinnamon cinnamon-common cinnamon-control-center cinnamon-control-center-data cinnamon-screensaver cos-artwork-cinnamon cos-artwork-common cos-artwork-gnome cos-backgrounds-iceblue cosbackup cos-common cosdrivers cos-flashplugin cos-flashplugin-11 cos-info-iceblue cosinstall cosinstall-icons cos-local-repository cos-mdm-themes cos-meta-core cos-mirrors cosnanny cossources cosstick cos-stylish-addon cossystem cos-themes cos-translations cosupdate cos-upgrade cosupload coswelcome coswifi cos-x-icons gir1.2-gtop-2.0 gnome-screenshot gnome-system-monitor libcinnamon-control-center1 libcinnamon-control-center-dev nemo nemo-data nemo-share ubuntu-system-adjustments" 
            fi
            mountdir
        fi

	#wangyu: Install apps from local application group.
	if [ $BUITSTEP -le 101 ] ; then
	    echo 101 >$BUILDCOSSTEP
   	    for line in `find $OUT/$PREAPP/appByLocalGroup/ -name "*.deb"`
	    do
                addrepository $line
    	    done
	    installdeball
            mountdir
	    if [ ! -x $OUTPATH/squashfs-root/usr/share/apps/goldendict ] ; then
		sudo mkdir $OUTPATH/squashfs-root/usr/share/apps/goldendict
	    fi
	    sudo tar xf $OUT/$PREAPP/appByLocalGroup/GolderDict_dictionary/dicts.tar.gz -C $OUTPATH/squashfs-root/usr/share/apps/goldendict/
	    sudo tar xf $OUT/$PREAPP/appByLocalGroup/GolderDict_dictionary/dictscache.tar.gz -C $OUTPATH/squashfs-root/etc/skel/
	fi

        #Change some icon\theme\applications name and so on.
        if [ $BUITSTEP -le 110 ] ; then
            echo 110 >$BUILDCOSSTEP
            sudo sh $T/build/release/mktheme.sh $OUTPATH || return
        fi
        if [ $BUITSTEP -le 120 ] ; then
            echo 120 >$BUILDCOSSTEP
            sudo sh $T/build/release/change_start_menu_icons.sh $OUTPATH || return
        fi
        if [ $BUITSTEP -le 130 ] ; then
            echo 130 >$BUILDCOSSTEP
            sudo sh $T/build/release/change_start_menu.sh $OUTPATH || return
        fi
        #fix a bug of wps when first opened.
        if [ $BUITSTEP -le 140 ] ; then
            echo 140 >$BUILDCOSSTEP
            sudo sh $T/build/release/set_username_for_WPS.sh $OUTPATH || return
            sudo sh $T/build/release/remove_update_userdir.sh $OUTPATH || return
            sudo sh $T/build/release/change_networking.sh $OUTPATH || return
        fi

        #Install cos boot splash
        #if [ $BUITSTEP -le 21 ] ; then
        #    sudo sh $T/build/release/installcossplash.sh $OUTPATH $APPPATH || return
        #    echo 21 >$BUILDCOSSTEP
        #fi

        umountdir

        if [ $BUITSTEP -le 150 ] ; then
            echo 150 >$BUILDCOSSTEP
            mkiso || return
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
        sh $T/build/core/getprepackage.sh $OUT $OUT/$PREAPP $RAWISOADDRESS $RAWPREAPPADDRESS
        addrepository $OUT/$PREAPP/gir1.2-gtop-2.0_2.28.4-3_i386.deb
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
    sudo mount -o bind /dev $OUT/out/squashfs-root/dev
    sudo mount -t proc -o bind /proc $OUT/out/squashfs-root/proc
    sudo mount none -t devpts $OUT/out/squashfs-root/dev/pts
    sudo mount none -t sysfs $OUT/out/squashfs-root/sys
}

function umountdir()
{
    sudo umount $OUT/out/squashfs-root/sys
    sudo umount $OUT/out/squashfs-root/dev/pts
    sudo umount $OUT/out/squashfs-root/dev
    sudo umount $OUT/out/squashfs-root/proc
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
        reprepro -b $REPOSITORY/debian includedeb iceblue $1
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
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --purge ubuntu-system-adjustments mint-mdm-themes mint-local-repository mint-meta-codecs mint-flashplugin mint-flashplugin-11 mint-meta-cinnamon mint-meta-core mint-search-addon mint-stylish-addon mintdrivers mint-artwork-cinnamon mintsources mintbackup mintstick mintwifi mint-artwork-gnome mint-artwork-common mint-backgrounds-olivia mintsystem mintwelcome mintinstall mintinstall-icons mintnanny mintupdate mintupload mint-info-cinnamon mint-common mint-mirrors mint-translations"
        sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --force-all --purge mint-themes mint-x-icons "
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
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --purge $@"
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
    mountdir

    sudo chroot $OUT/out/squashfs-root /bin/bash -c 'sudo apt-get update -o Dir::Etc::sourcelist="sources.list.d/cos-repository.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"'
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get install -y --force-yes --reinstall -o Dir::Etc::sourcelist=\"sources.list.d/cos-dev-repository.list\" $deblist"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get clean"
    echo `echo $deblist | wc -w` package\(s\) has been installed.

    umountdir
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
    mountdir

    echo "deb file:///repository/debian iceblue main" > /tmp/cos-dev-repository.list
    sudo mv /tmp/cos-dev-repository.list $OUT/out/squashfs-root/etc/apt/sources.list.d/
    sudo chroot $OUT/out/squashfs-root /bin/bash -c 'sudo apt-get update -o Dir::Etc::sourcelist="sources.list.d/cos-dev-repository.list" -o Dir::Etc::sourceparts="-" -o APT::Get::List-Cleanup="0"'
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get install -y --force-yes --reinstall -o Dir::Etc::sourcelist=\"sources.list.d/cos-dev-repository.list\" $deblist"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get clean"
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
        installdeb $deblist
    else
        installdebonline $deblist
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
        return
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
        return
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
