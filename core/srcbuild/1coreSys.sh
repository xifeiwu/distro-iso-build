ARCH=i386 #
RELEASE=raring #
# sudo apt-get install debootstrap
mkdir -p work/chroot
cd work

sudo debootstrap --arch=i386 raring chroot http://192.168.160.169/ubuntu/
