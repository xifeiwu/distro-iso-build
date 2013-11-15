function hh() {
cat <<EOF
Invoke ". build/envsetup.sh" from your shell to add the following functions to your environment:
- croot:   Changes directory to the top of the tree.
- cmaster: repo forall -c git checkout -b master remotes/m/master
- mcos:    Build all and generate iso.
- mall:    Build all packages in cos and desktop dir, and then move these .deb .tar.gz .dsc .changes file to workout/app dir.
- m:       Same as mc.
- mc:      Builds the package and clean the source dir in the current directory.
- mnc:     Builds the package and doesn't clean the source dir in the current directory.
- uniso:   Export iso file to workout/out dir.
- mkiso:   Generate iso file into workout dir from workout/out file.
- cgrep:   Greps on all local C/C++ files.
- jgrep:   Greps on all local Java files.
- resgrep: Greps on all local res/*.xml files.
- godir:   Go to the directory containing a file.

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
    hh
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

function cmaster()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return
    fi
    
    repo forall -c git checkout -b master remotes/m/master
}

function setpaths()
{
    T=$(gettop)
    if [ ! "$T" ]; then
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return
    fi

    export OUT=$T/workout
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

function uniso()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -e $OUT ] ; then
            mkdir $OUT
        fi
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

function mcos()
{
    ISONLINE=0
    if [ ! $# -lt 1 ] ; then 
        if [ "$1" == "--online" ] ; then
            ISONLINE=1
        else
            echo ERROR: unknown param: $1
            return
        fi
    fi
    T=$(gettop)
    if [ "$T" ]; then
        getprepkg || return
        mall || return
        uniso || return

        #Install zh_CN deb and Input Method deb.
        OUTPATH=$OUT/out
        APPPATH=$OUT/preapp
        sudo sh $T/build/release/installzh_CN.sh $OUTPATH $APPPATH || return

        #Install popular software
        sudo sh $T/build/release/installwps.sh $OUTPATH $APPPATH || return
        sudo sh $T/build/release/installchrome.sh $OUTPATH $APPPATH || return
        sudo sh $T/build/release/installvim.sh $OUTPATH $APPPATH || return
        sudo sh $T/build/release/installwineqq.sh $OUTPATH $APPPATH || return

        #Install ssh and close root user with ssh authority.
        sudo sh $T/build/release/installssh.sh $OUTPATH $APPPATH || return

        #Install Self software
        sudo sh $T/build/release/installrdpdesk.sh $OUTPATH $APPPATH || return
        sudo sh $T/build/release/installqtadb.sh $OUTPATH $APPPATH || return

        #Change iso files
        sudo sh $T/build/release/change_iso_files.sh $OUTPATH || return
        sudo sh $T/build/release/remove_wubi.sh $OUTPATH || return

        #Change some zh_CN LC_MESSAGES
        sudo sh $T/build/release/change_zh_CN.sh $OUTPATH || return

        #Change system name in some where. This shell file also will install some software in cos source list.
        sudo sh $T/build/release/ubiquity.sh $T/build/release/ $OUTPATH || return

        if [ $ISONLINE == 1 ] ; then
            sudo sh $T/build/release/packages.sh $T/build/release/ $OUTPATH || return
        else
            sudo mv $OUT/appbuilt $OUT/out/squashfs-root/
            sudo sh $T/build/core/packages_locale.sh $T/build/release/ $OUTPATH || return
            sudo mv $OUT/out/squashfs-root/appbuilt $OUT/
        fi

        #Change some icon\theme\applications name and so on.
        sudo sh $T/build/release/mktheme.sh $OUTPATH || return
        sudo sh $T/build/release/change_start_menu_icons.sh $OUTPATH || return
        sudo sh $T/build/release/change_start_menu.sh $OUTPATH || return

        #fix a bug of wps when first opened.
        sudo sh $T/build/release/set_username_for_WPS.sh $OUTPATH || return

        #Install cos boot splash
        sudo sh $T/build/release/installcossplash.sh $OUTPATH $APPPATH || return

        mkiso || return
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function m()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -f debian/rules ] ; then
            echo ERROR: No file debian/rules founded. Maybe this is not a debian package source dir.
            return
        fi 
        dpkg-buildpackage -tc $*
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function mm()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -f debian/rules ] ; then
            echo ERROR: No file debian/rules founded. Maybe this is not a debian package source dir.
            return
        fi 
        dpkg-buildpackage $*
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function mc()
{
    m $*
}

function mnc()
{
    T=$(gettop)
    if [ "$T" ]; then
        dpkg-buildpackage
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function mall()
{
    T=$(gettop)
    if [ "$T" ]; then
	sh $T/build/core/buildpackage.sh $OUT/appbuilt
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
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

function cgrep()
{
    find . -name .repo -prune -o -name .git -prune -o -type f \( -name '*.c' -o -name '*.cc' -o -name '*.cpp' -o -name '*.h' \) -print0 | xargs -0 grep --color -n "$@"
}

function resgrep()
{
    for dir in `find . -name .repo -prune -o -name .git -prune -o -name res -type d`; do find $dir -type f -name '*\.xml' -print0 | xargs -0 grep --color -n "$@"; done;
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

function getprepkg ()
{
    T=$(gettop)
    if [ "$T" ]; then
        cd $(gettop)
        sh $T/build/core/getprepackage.sh $OUT
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
    
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
