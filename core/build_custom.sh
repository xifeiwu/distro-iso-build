function setcustomenv()
{
    export BASEOUTNAME=workout_base
    export BASEOUT=$T/$BASEOUTNAME
    export WSHAREPATH=box@192.168.162.142:/home/box/Workspace/Public/wshare
    export SERVERPATH=/home/box/Workspace/Public/wshare
    export SERVERAPPPATH=/home/box/Workspace/Public/app
}

function mkworkoutdir()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -d $OUT ]; then
            mkdir -p $OUT
        fi
        if [ -e $APPPATH ]; then
            sudo rm -rf $APPPATH
        fi
        ln -s $1/$PREAPP $APPPATH

        if [ -e $OUT/$RAWSQUASHFSNAME ]; then
            sudo rm -rf $OUT/$RAWSQUASHFSNAME
        fi
        ln -s $1/$RAWSQUASHFSNAME $OUT/$RAWSQUASHFSNAME

        if [ -e $OUT/$REPODIRNAME ]; then
            sudo rm -rf $OUT/$REPODIRNAME
        fi
        ln -s $1/$REPODIRNAME $OUT/$REPODIRNAME

        if [ -e $OUT/$APPOUT ]; then
            sudo rm -rf $OUT/$APPOUT
        fi
        ln -s $1/$APPOUT $OUT/$APPOUT

        echo "rsync out"
        if [ -d $OUT/out ]; then
#            sudo rm -rf $OUT/out
            cclean out -y
        fi
#        rsync -av --progress $1/out/ $OUT/out
        if [ -d $1/out ]; then
            cp -a $1/out $OUT/out
        fi

        echo "uniso $RAWSQUASHFSNAME"
        uniso || return 1
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function getbaseprepkg ()
{
    T=$(gettop)
    if [ "$T" ]; then
        if [ ! -e $OUT ] ; then
            mkdir $OUT
        fi
        cd $(gettop)
        addrepository $OUT/$PREAPP/gir1.2-gtop-2.0_2.28.4-3_i386.deb || return 1
        addrepository $OUT/$PREAPP/fcitx-frontend-qt5_0.1.1-0~22~ubuntu13.04.1_i386.deb || return 1
        addrepository $OUT/$PREAPP/fcitx-libs-qt5_0.1.1-0~22~ubuntu13.04.1_i386.deb || return 1
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
        return 1
    fi
}

function _mbaseos()
{
    BUITSTEP=0
    ISONSERVER=0
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
        if [ "$i" == "--onserver" ] ; then
            ISONSERVER=1
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
#            getprepkg || return 1
            getbaseprepkg || return 1
        fi
        if [ $BUITSTEP -le 20 ] ; then
            echo 20 >$BUILDOSSTEP
            checktools || return 1
            createlink || return 1
            mall || return 1
        fi
        if [ $BUITSTEP -le 25 ] ; then
            echo 25 >$BUILDOSSTEP
	    mroot || return 1
	    mrootbuilder || return 1  
        fi
        if [ $BUITSTEP -le 26 ] ; then
            echo 26 >$BUILDOSSTEP
            if [ -e $OUT/$RAWSQUASHFSNAME ]; then
                echo "rm $RAWSQUASHFSNAME"
                sudo rm -rf $OUT/$RAWSQUASHFSNAME
            fi
            echo "mksquashfs"
            sudo mksquashfs $OUT/out/squashfs-root $OUT/$RAWSQUASHFSNAME
            echo "rm $OUT/out/squashfs-root"
#            cclean out -y

            if [ $ISONSERVER -eq 1 ] ; then  #若jenkins，则需要上传baseos内容
                echo "rsync to jenkins"
#                rsync -av --delete --progress $OUT/ $SERVERPATH
                rm -rf $SERVERPATH/*
                rsync -av --progress $OUT/$RAWSQUASHFSNAME $SERVERPATH
                rsync -av --delete --progress $OUT/$APPOUT $SERVERPATH
                rsync -av --delete --progress $OUT/$REPOSITORY $SERVERPATH
                rsync -av --delete --progress $SERVERAPPPATH $SERVERPATH
            else 
                if [ -d $BASEOUT ]; then
                    sudo rm -rf $BASEOUT
                fi
                echo "mv $BASEOUT"
                mv $OUT $BASEOUT
            fi
            echo "rsync succeed!"
        fi
    else
        echo "Couldn't locate the top of the tree.  Try setting TOP."
    fi
}

function _mcustomos()
{
    ISONLINE=0
    BUITSTEP=0
    IS4LENOVO=0
    IS4S3G=0
    IS4TEST=0
    IS4DEBUG=0
    ISFROMSRC=0
    IS4OEM=0
    ISLOCAL=0
    ISONSERVER=0
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
        elif [ "$i" == "--local" ] ; then
            ISLOCAL=1
        elif [ "$i" == "--onserver" ] ; then
            ISONSERVER=1
        else
            if [ "$i" -gt 0 ] 2>/dev/null ; then
                BUITSTEP=$i
            elif [ "$i" == 0 ] ; then
                BUITSTEP=$i
            fi
        fi
    done
    echo "BUITSTEP = $BUITSTEP"

    T=$(gettop)
    if [ "$T" ]; then
        #Install zh_CN deb and Input Method deb.
        OUTPATH=$OUT/out
        APPPATH=$OUT/$PREAPP

        if [ $BUITSTEP -le 30 ] ; then
            echo 30 >$BUILDOSSTEP
            if [ $ISONSERVER -eq 1 ] ; then
                echo "begin mkworkoutdir onserver"
                mkworkoutdir $SERVERPATH
            else
                if [ $ISLOCAL -eq 1 ] ; then
                    if [ ! -d $BASEOUT ] ; then
                        echo "Error! workout_base dir not found.Please execute _mbaseos 0"
                        return 1
                    else
                        echo "begin mkworkoutdir onlocal"
                        mkworkoutdir $BASEOUT
                    fi
                else
                    if [ -d $OUT ]; then
                        cclean out -y
                        sudo rm -rf $APPPATH $OUT/$RAWSQUASHFSNAME $OUT/$REPODIRNAME $OUT/$APPOUT
                    fi
                    
                    echo "rsync -av --delete --progress $WSHAREPATH/ $OUT from server"
                    rsync -av --delete --exclude="cdos*.iso" --progress $WSHAREPATH/ $OUT
                    uniso || return 1
                fi
            fi
        fi

	if [ $BUITSTEP -le 31 ] ; then
            echo 31 >$BUILDOSSTEP
	    if [ $ISFROMSRC -eq 1 ] ; then
                echo "begin cp"
                sudo cp $T/build/release/tmpfiles/mdm/mdm.conf $OUTPATH/squashfs-root/etc/mdm/ || return 1
                echo "uninstalldeb"
                uninstalldeb "account-plugin-facebook account-plugin-flickr account-plugin-google account-plugin-twitter alacarte appmenu-gtk appmenu-gtk3 appmenu-qt appmenu-qt5 apport apport-symptoms bamfdaemon banshee-extension-soundmenu bison cdparanoia cdrdao compiz compiz-core compiz-gnome compiz-plugins-default curl dconf-tools docbook-xsl flex freepats friends-facebook friends-twitter gir1.2-panelapplet-4.0 gir1.2-rb-3.0 gir1.2-unity-5.0 gnome-applets gnome-applets-data gnome-control-center gnome-control-center-data gnome-control-center-signon gnome-control-center-unity gnome-media gnome-session gnome-session-fallback gnome-user-guide gromit gstreamer0.10-gnomevfs hud humanity-icon-theme icoutils indicator-applet-complete indicator-appmenu indicator-datetime indicator-messages indicator-power indicator-printers indicator-session indicator-sound k3b k3b-data kate-data katepart kde-runtime kde-runtime-data kde-style-oxygen kde-window-manager kde-window-manager-common kdelibs-bin kdelibs5-data kdelibs5-plugins kdoctools kubuntu-debug-installer libattica0.4 libbamf3-1 libbison-dev libcompizconfig0 libdlrestrictions1 libencode-locale-perl libfile-listing-perl libfl-dev libflac++6 libfont-afm-perl libgnome-control-center1 libgnome-media-profiles-3.0-0 libgnome2-canvas-perl libgnome2-perl libgnome2-vfs-perl libgnomevfs2-extra libhtml-form-perl libhtml-format-perl libhtml-parser-perl libhtml-tagset-perl libhtml-tree-perl libhttp-cookies-perl libhttp-daemon-perl libhttp-date-perl libhttp-message-perl libhttp-negotiate-perl libibus-1.0-0 libio-socket-ssl-perl libk3b6 libkactivities-bin libkactivities-models1 libkactivities6 libkatepartinterfaces4 libkcddb4 libkcmutils4 libkde3support4 libkdeclarative5 libkdecorations4abi1 libkdecore5 libkdesu5 libkdeui5 libkdewebkit5 libkdnssd4 libkemoticons4 libkfile4 libkhtml5 libkidletime4 libkio5 libkjsapi4 libkjsembed4 libkmediaplayer4 libknewstuff3-4 libknotifyconfig4 libkntlm4 libkparts4 libkpty4 libkrosscore4 libktexteditor4 libkwineffects1abi4 libkwinglutils1abi1 libkwinnvidiahack4 libkworkspace4abi2 libkxmlrpcclient4 liblwp-mediatypes-perl liblwp-protocol-https-perl libmusicbrainz5-0 libmysqlclient18 libnepomuk4 libnepomukcore4abi1 libnepomukquery4a libnepomukutils4 libnet-http-perl libnet-ssleay-perl libntrack-qt4-1 libntrack0 libnux-4.0-0 libphonon4 libplasma3 libpolkit-qt-1-1 libpoppler-qt4-4 libqapt2 libqapt2-runtime libqca2 libqt4-qt3support libqt4-sql-mysql librhythmbox-core6 libsolid4 libsoprano4 libstreamanalyzer0 libstreams0 libthreadweaver4 libunity-core-6.0-5 libunity-misc4 libunity-webapps0 libvirtodbc0 libwww-perl libwww-robotrules-perl libxcb-damage0 libxml2-utils mysql-common nautilus nepomuk-core nepomuk-core-data notification-daemon ntrack-module-libnl-0 odbcinst odbcinst1debian2 oxygen-icon-theme phonon phonon-backend-gstreamer plasma-scriptengine-javascript python-zeitgeist python3-apport python3-dbus.mainloop.qt python3-distupgrade python3-problem-report python3-pyqt4 python3-sip python3-update-manager qapt-batch rhythmbox rhythmbox-data rhythmbox-mozilla rhythmbox-plugin-cdrecorder rhythmbox-plugin-zeitgeist rhythmbox-plugins rhythmbox-ubuntuone shared-desktop-ontologies soprano-daemon ubiquity-frontend-kde ubuntu-release-upgrader-core unity unity-asset-pool unity-common unity-lens-applications unity-lens-files unity-lens-friends unity-lens-music unity-lens-photos unity-lens-shopping unity-lens-video unity-scope-gdrive unity-scope-musicstores unity-scope-video-remote unity-services unity-webapps-service update-manager-core vcdimager virtuoso-minimal virtuoso-opensource-6.1-bin virtuoso-opensource-6.1-common xul-ext-ubufox zeitgeist zeitgeist-core zeitgeist-datahub build-essential debhelper dh-apparmor dpkg-dev firefox-globalmenu g++ g++-4.7 html2text kbuild libalgorithm-diff-perl libalgorithm-diff-xs-perl libalgorithm-merge-perl libmail-sendmail-perl libstdc++6-4.7-dev libsys-hostname-long-perl module-assistant openjdk-6-jre openjdk-6-jre-headless openjdk-6-jre-lib po-debconf thunderbird-globalmenu virtualbox-guest-source xchat-indicator" || return 1
            fi
	fi

        mountdir || return 1

        #Reset sourcelist
        if [ $BUITSTEP -le 35 ] ; then
            echo 35 >$BUILDOSSTEP
            sudo cp $T/build/core/sources.list $OUTPATH/squashfs-root/etc/apt/sources.list.d/official-package-repositories.list || return 1
            sudo cp $T/build/core/preferences $OUTPATH/squashfs-root/etc/apt/preferences || return 1
            sudo cp $T/build/core/cdos-keyring_2014.03.07_all.deb $OUTPATH/squashfs-root/tmp/ || return 1
            sudo chroot $OUTPATH/squashfs-root /bin/bash -c "dpkg -i /tmp/cdos-keyring_2014.03.07_all.deb" || return 1
            sudo rm $OUTPATH/squashfs-root/tmp/cdos-keyring_2014.03.07_all.deb || return 1
            sudo rm $OUTPATH/squashfs-root/etc/apt/sources.list || return 1
            sudo touch $OUTPATH/squashfs-root/etc/apt/sources.list || return 1
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
                installdeb "cinnamon cinnamon-common cinnamon-control-center cinnamon-control-center-data cinnamon-screensaver mint-artwork-cinnamon mint-artwork-common mint-artwork-gnome mint-backgrounds-olivia mintbackup mint-common mintdrivers mint-flashplugin mint-flashplugin-11 mint-info-cinnamon mintinstall-icons mint-local-repository mint-mdm-themes mint-meta-core mint-mirrors mintsources mintnanny mintstick mint-stylish-addon mintsystem mint-themes mint-translations mintupdate cdos-upgrade mintupload mintwelcome mintwifi mint-x-icons gir1.2-gtop-2.0 libfcitx-qt5-0 gnome-screenshot gnome-system-monitor libcinnamon-control-center1 nemo nemo-data nemo-share ubuntu-system-adjustments libtimezonemap1 gir1.2-timezonemap-1.0 cdospatchmgr gnome-icon-theme-symbolic" || return 1
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

	#wangyu: Install software center
        if [ $BUITSTEP -le 102 ] ; then
            echo 102 >$BUILDOSSTEP
	    sudo cp -r $OUT/$PREAPP/cdossoftcenter $OUTPATH/squashfs-root/tmp/ || return 1
	    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y install libqt5core5 libqt5gui5 libqt5network5 libqt5dbus5 libxcb-icccm4 libxcb-image0 libxcb-render-util0 libxcb-sync0 libqt5opengl5 libqt5printsupport5 libqt5sql5 libqt5widgets5" || return 1
	    sudo chroot $OUT/out/squashfs-root /bin/bash -c "apt-get -y --force-yes autoremove" || return 1
	    sudo chroot $OUT/out/squashfs-root /bin/bash -c "dpkg -i /tmp/cdossoftcenter/*.deb" || return 1
	    sudo rm -rf $OUT/out/squashfs-root/tmp/cdossoftcenter
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

setcustomenv
