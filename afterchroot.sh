#!/usr/bin/bash

# Enable TRIM
sed -i 's/rw/rw,noatime,discard/g' /etc/fstab

# Create configs for system
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "de_DE.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=en_US.UTF-8" > /etc/locale.conf
export LANG=en_US.UTF-8
ln -s /usr/share/zoneninfo/Europe/Berlin /etc/localtime
hwclock --systohc --localtime
echo "arch" > /etc/hostname

# Enable networking
systemctl enable NetworkManager.service

# Enable energy management services
cat << EOF
[Unit]
Desctiption=Powertop Service

[Service]
Type=oneshot
ExecStart=/usr/bin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF
systemctl enable powertop.service
systemctl enable cpupower

# Add KMS module to loading modules
sed -i -e 's/MODULES=""/MODULES="i915"/g' /etc/mkinitcpio.conf

# generate Kernel image
mkinitcpio -p linux

# Install and customize GRUB
grub-install --target=i386-pc --recheck --debug $1
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g' /etc/default/grub
sed -i 's/quiet/modprobe.blacklist=ehci_pci/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Tell systemd how to handle power key press and lid close
sed -i 's/.*HandlePowerKey.*/HandlePowerKey=ignore/g' /etc/systemd/logind.conf
sed -i 's/.*HandleLidSwitch.*/HandlePowerKey=suspend/g' /etc/systemd/logind.conf

# Set xfce4 settings for battery and ac
sed -i 's/action-on-battery" type="uint" value=".*"/action-on-battery" type="uint" value="1"/g' /home/$2/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml
#sed -i 's/action-on-ac" type="uint" value=".*"/action-on-ac" type="uint" value="1"/g' /home/$2/.config/xfce4/xfconf/xfce-perchannel-xml/xfce4-power-manager.xml

# Enable login manager at boot
systemctl enable lightdm.service
echo "greeter-setup-script=/usr/bin/numlockx on" >> /etc/lightdm/lightdm.conf

# Create User
useradd -m -s /usr/bin/zsh $2

# Compile compton and download settings
mkdir compton
chown $2:$2 compton
cd compton
wget https://aur.archlinux.org/packages/co/compton/PKGBUILD

echo "$2 ALL=(ALL) ALL" >> /etc/sudoers

sudo $2 -c 'makepkg -s'
pacman -U --noconfirm /home/$2/compton/compton*xz

sed -i "/^$2/d" /etc/sudoers

rm -rf /home/$2/compton

mkdir -p /home/$2/.config/autostart/
chown -R $2:$2 /home/$2/.config

wget https://raw.githubusercontent.com/DanielBilanovic/archc720/master/xbindkeysrc /home/$2/.xbindkeysrc
chown $2:$2 /home/$2/.xbindkeysrc

wget https://raw.githubusercontent.com/DanielBilanovic/archc720/master/xbindkeysrc.desktop /home/$2/.config/autostart/xbindkeys.desktop
chown $2:$2 /home/$2/.config/autostart/xbindkeys.desktop

wget https://raw.githubusercontent.com/DanielBilanovic/archc720/master/compton.desktop /home/$2/.config/autostart/compton.desktop
chown $2:$2 /home/$2/.config/autostart/compton.desktop

wget https://raw.githubusercontent.com/DanielBilanovic/archc720/master/compton.conf /home/$2/.config/autostart/compton.conf
chown $2:$2 /home/$2/.compton.conf

wget https://raw.githubusercontent.com/DanielBilanovic/archc720/master/50-synaptics.conf /etc/X11/xorg.conf.d/50-synaptics.conf

# Remove script file
rm ${0}

echo "CHANGE USER AND ROOT PASSWORD!"
exit