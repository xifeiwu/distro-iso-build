function hh() {
cat <<EOF
Invoke ". build/envsetup.sh" from your shell to add the following functions to your environment:
- croot:     Changes directory to the top of the tree.
- cmaster:   repo forall -c git checkout -b master remotes/m/master
- check:     Check the tools and dependencies to should be installed.
- getprepkg: Get raw iso and some deb packages such as wps.
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
}

function resource()
{
    source $T/build/envsetup.sh
}

function setpaths()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return
    fi

    export OUT=$T/workout
    export APPOUT=appout
    export REPOSITORY=$OUT/repository
    export BUILDCOSSTEP=$OUT/buildcosstep
    export BUILDALLSTEP=$OUT/buildallstep
    export ISOPATH=$OUT/linuxmint-15-cinnamon-dvd-32bit-1-4kernel-3.iso
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
    fi
}

function cmaster()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return
    fi
    
    repo forall -c git checkout -b master remotes/m/master
}

function checktools()
{
    dpkg -s squashfs-tools > /dev/null
    if [ ! $? == 0 ] ; then
        echo ERROR: squashfs-tools has not been installed.
        dpkg -s reprepro > /dev/null
        if [ ! $? == 0 ] ; then
            echo ERROR: reprepro has not been installed.
        fi
        return 1
    fi
    dpkg -s reprepro > /dev/null
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
                echo checking $dir
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
    fi
}

function uniso()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -e $OUT ] ; then
            mkdir $OUT
        fi
        checktools || return 1
        sudo sh $T/build/uniso.sh $ISOPATH $OUT/out
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function mkiso()
{
    T=$(gettop)
    if [ "$T" ]; then
        sudo sh $T/build/mkiso.sh $OUT/out $OUT
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function m()
{
    T=$(gettop)
    mm -tc $*
}

function mm()
{
    T=$(gettop)
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
        if ls ../*.* >/dev/null 2>&1 ; then
            echo ERROR: The files in parent dir should be moved into somewhere. Maybe they are the last files generated when last building.
            echo tips: cmove: you should enter cmove command to move this files into $OUT/$APPOUT dir.
            return 1
        fi
        dpkg-checkbuilddeps
        if [ ! $? == 0 ] ; then
            return 1
        fi
        dpkg-buildpackage -d $*
        echo
        echo The list of deb files generated.
        ls -1 ../*.deb
        echo
        HASDEBFILE=0
        for file in `ls ../*.deb | sort`
        do
            if [ -f $file ] ; then
                HASDEBFILE=1
                DEBNAME=`dpkg -f $file Package`
                addrepository $file
                if [ $ISINSTALL == 1 ] ; then
                    installdeb $DEBNAME
                fi 
            fi
        done 
        if [ $HASDEBFILE == 0 ] ; then
            echo ERROR: No deb file generated. Some error happened in dpkg-buildpackage -d $*
            return 1
        fi
        echo Finished. These deb files above has been added into repository.
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
    fi
}

function mall()
{
    T=$(gettop)
    LASTSTEP=0
    if [ -e $BUILDALLSTEP ] ; then
        LASTSTEP=`cat $BUILDALLSTEP`
    fi
    for i in "$@"
    do
        if [ "$i" == "--online" ] ; then
            ISONLINE=1
        else
            if [ "$i" -ge 0 ] 2>/dev/null ; then
                LASTSTEP=$i
            fi
        fi
    done
    if [ "$T" ]; then
        if [ ! -e $OUT ] ; then
            mkdir $OUT
        fi
        echo Building all deb packages

        SRCDesktopPATH=$T/desktop
        SRCCOSPATH=$T/cos
        CURDIR=$PWD
        if [ $LASTSTEP == 0 ] ; then
            checkdepall || grep dpkg-checkbuilddeps
            if [ $? -ne 0 ] ; then
                echo Error: some dependencis has not been met.
                return 1
            fi
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
        if [ ! -e $OUT ] ; then
            mkdir $OUT
        fi
        echo Building COS Desktop ...
        if [ $BUITSTEP -lt 1 ] ; then
            getprepkg || return
            echo 1 >$BUILDCOSSTEP
        fi
        if [ $BUITSTEP -lt 2 ] ; then
            checktools || return
            mall || return
            echo 2 >$BUILDCOSSTEP
        fi
        if [ $BUITSTEP -lt 3 ] ; then
            uniso || return
            echo 3 >$BUILDCOSSTEP
        fi

        #Install zh_CN deb and Input Method deb.
        OUTPATH=$OUT/out
        APPPATH=$OUT/preapp

        mountdir

        if [ $BUITSTEP -lt 4 ] ; then
            sudo sh $T/build/release/installzh_CN.sh $OUTPATH $APPPATH || return
            echo 4 >$BUILDCOSSTEP
        fi

        #Install popular software
        if [ $BUITSTEP -lt 5 ] ; then
            sudo sh $T/build/release/installwps.sh $OUTPATH $APPPATH || return
            echo 5 >$BUILDCOSSTEP
        fi
        if [ $BUITSTEP -lt 6 ] ; then
            sudo sh $T/build/release/installchrome.sh $OUTPATH $APPPATH || return
            echo 6 >$BUILDCOSSTEP
        fi
        if [ $BUITSTEP -lt 7 ] ; then
            sudo sh $T/build/release/installvim.sh $OUTPATH $APPPATH || return
            echo 7 >$BUILDCOSSTEP
        fi
        if [ $BUITSTEP -lt 8 ] ; then
            sudo sh $T/build/release/installwineqq.sh $OUTPATH $APPPATH || return
            echo 8 >$BUILDCOSSTEP
        fi

        #Install ssh and close root user with ssh authority.
        if [ $BUITSTEP -lt 9 ] ; then
            sudo sh $T/build/release/installssh.sh $OUTPATH $APPPATH || return
            echo 9 >$BUILDCOSSTEP
        fi

        #Install Self software
        if [ $BUITSTEP -lt 10 ] ; then
            sudo sh $T/build/release/installrdpdesk.sh $OUTPATH $APPPATH || return
            echo 10 >$BUILDCOSSTEP
        fi
        if [ $BUITSTEP -lt 11 ] ; then
            sudo sh $T/build/release/installqtadb.sh $OUTPATH $APPPATH || return
            echo 11 >$BUILDCOSSTEP
        fi

        #Change iso files
        if [ $BUITSTEP -lt 12 ] ; then
            sudo sh $T/build/release/change_iso_files.sh $OUTPATH || return
            echo 12 >$BUILDCOSSTEP
        fi
        if [ $BUITSTEP -lt 13 ] ; then
            sudo sh $T/build/release/remove_wubi.sh $OUTPATH || return
            echo 13 >$BUILDCOSSTEP
        fi

        #Change some zh_CN LC_MESSAGES
        if [ $BUITSTEP -lt 14 ] ; then
            sudo sh $T/build/release/change_zh_CN.sh $OUTPATH || return
            echo 14 >$BUILDCOSSTEP
        fi

        #Change system name in some where. This shell file also will install some software in cos source list.
        if [ $BUITSTEP -lt 15 ] ; then
            sudo sh $T/build/release/ubiquity.sh $T/build/release/ $OUTPATH || return
            echo 15 >$BUILDCOSSTEP
        fi

        if [ $BUITSTEP -lt 16 ] ; then
            sudo sh $T/build/core/set_sourcelist.sh $OUTPATH/squashfs-root || return
            if [ $ISONLINE == 1 ] ; then
                sudo sh $T/build/release/packages.sh $T/build/release/ $OUTPATH || return
            else
                uninstallalldeb || return
                installdeb "ubuntu-system-adjustments cos-mdm-themes cos-local-repository cos-meta-codecs cos-flashplugin cos-flashplugin-11 cos-meta-cinnamon cos-meta-core cos-stylish-addon cosdrivers cos-artwork-cinnamon cossources cosbackup cosstick coswifi cos-artwork-gnome cos-themes cos-artwork-common cos-backgrounds-iceblue cos-x-icons cossystem coswelcome cosinstall cosinstall-icons cosnanny cosupdate cosupload cos-info-iceblue cos-common cos-mirrors cos-translations cinnamon cinnamon-common cinnamon-screensaver nemo nemo-data nemo-share cos-upgrade" 
                mountdir
            fi
            echo 16 >$BUILDCOSSTEP
        fi

        #Change some icon\theme\applications name and so on.
        if [ $BUITSTEP -lt 17 ] ; then
            sudo sh $T/build/release/mktheme.sh $OUTPATH || return
            echo 17 >$BUILDCOSSTEP
        fi
        if [ $BUITSTEP -lt 18 ] ; then
            sudo sh $T/build/release/change_start_menu_icons.sh $OUTPATH || return
            echo 18 >$BUILDCOSSTEP
        fi
        if [ $BUITSTEP -lt 19 ] ; then
            sudo sh $T/build/release/change_start_menu.sh $OUTPATH || return
            echo 19 >$BUILDCOSSTEP
        fi
        #fix a bug of wps when first opened.
        if [ $BUITSTEP -lt 20 ] ; then
            sudo sh $T/build/release/set_username_for_WPS.sh $OUTPATH || return
            echo 20 >$BUILDCOSSTEP
        fi

        #Install cos boot splash
        if [ $BUITSTEP -lt 21 ] ; then
            sudo sh $T/build/release/installcossplash.sh $OUTPATH $APPPATH || return
            echo 21 >$BUILDCOSSTEP
        fi

        umountdir

        if [ $BUITSTEP -lt 22 ] ; then
            mkiso || return
            echo 100 >$BUILDCOSSTEP
        fi
        echo Finish building COS Desktop.
        echo
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
        sh $T/build/core/getprepackage.sh $OUT
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
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

function uninstallalldeb()
{
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --purge ubuntu-system-adjustments mint-mdm-themes mint-local-repository mint-meta-codecs mint-flashplugin mint-flashplugin-11 mint-meta-cinnamon mint-meta-core mint-search-addon mint-stylish-addon mintdrivers mint-artwork-cinnamon mintsources mintbackup mintstick mintwifi mint-artwork-gnome mint-artwork-common mint-backgrounds-olivia mintsystem mintwelcome mintinstall mintinstall-icons mintnanny mintupdate mintupload mint-info-cinnamon mint-common mint-mirrors mint-translations"
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg --force-all --purge mint-themes mint-x-icons "
}

function cmove()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -f debian/rules ] ; then
            echo ERROR: No file debian/rules founded. Maybe this is not a debian package source dir.
            return 1
        fi
        for file in `ls ../ | sort`
        do
            if [ -f ../$file ] ; then
                mv ../$file $OUT/$APPOUT
            fi
        done 
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
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
    fi
    
}

function installdeb()
{
    echo These deb package $@ will be installed in $OUT/out/squashfs-root
    if [ $# -lt 1 ] ; then
        echo Error: no debname param
        return 1
    fi
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
    sudo chroot $OUT/out/squashfs-root /bin/bash -c "sudo apt-get install -y --force-yes --reinstall -o Dir::Etc::sourcelist=\"sources.list.d/cos-dev-repository.list\" $@ "
    sudo rm $OUT/out/squashfs-root/etc/apt/sources.list.d/cos-dev-repository.list

    umountdir
    sudo umount $OUT/out/squashfs-root/repository
    sudo rmdir $OUT/out/squashfs-root/repository
}

function installalldeb()
{
    installdeb "ubuntu-system-adjustments cos-mdm-themes cos-local-repository cos-meta-codecs cos-flashplugin cos-flashplugin-11 cos-meta-cinnamon cos-meta-core cos-stylish-addon cosdrivers cos-artwork-cinnamon cossources cosbackup cosstick coswifi cos-artwork-gnome cos-themes cos-artwork-common cos-backgrounds-iceblue cos-x-icons cossystem coswelcome cosinstall cosinstall-icons cosnanny cosupdate cosupload cos-info-iceblue cos-common cos-mirrors cos-translations cinnamon cinnamon-common cinnamon-screensaver nemo nemo-data nemo-share cos-upgrade" 
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
setpaths
addcompletions
