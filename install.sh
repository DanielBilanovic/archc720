#!/usr/bin/bash
# This script installs Arch Linux automatically on a Acer C720 Chromebook.
# It expects the device name where it should be installed and the name of the user to create
# The Partition will be 12G, swap will be as big as the rest of the device.

# Create 2 partitions, first is 12GB big the second is the rest of the drive.
if [[ $1 ]] ; then
        dd if=/dev/zero of=$1 bs=512 count=1 conv=notrunc
        echo -e "o\nn\n\n\n\n+12G\nn\n\n\n\n\nw" | fdisk $1
else
        echo "Please restart script and enter path to drive to install to (e.g. /dev/sda)!"
        exit
fi
mkswap ${1}2
swapon ${1}2
mkfs.ext4 ${1}1
mount ${1}1 /mnt

# Delete all non-german mirrors from the mirrorlist
sed -i '/text\|\.de/!d' /etc/pacman.d/mirrorlist

# Install base system and wanted packages
pacstrap -i /mnt --noconfirm base base-devel vim dialog gptfdisk openssh grub os-prober zsh xorg-server xorg-server-utils xorg-apps xorg-xinit xf86-video-intel xfce4 xfce4-goodies numlockx lightdm lightdm-gtk-greeter xterm firefox htop intel-ucode wireless_tools networkmanager xf86-input-synaptics powertop pulseaudio pulseaudio-alsa gnome-alsamixer pavucontrol vlc cmake glib-networking network-manager-applet xbindkeys xdotool wget cpupower evince xarchiver zip p7zip lzop cpio unrar

# Generate fstab
genfstab -U -p /mnt > /mnt/etc/fstab

# chroot into new system and pass the other file to bash
wget https://raw.githubusercontent.com/DanielBilanovic/archc720/master/afterchroot.sh
chmod +x afterchroot.sh
cp afterchroot.sh /mnt
arch-chroot /mnt /bin/bash afterchroot.sh $1 $2

# chroot again to change passwords
arch-chroot /mnt
