#!/usr/bin/env bash

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

# Create energy management service-file
cat << EOF >> /etc/systemd/system/powertop.service
[Unit]
Desctiption=Powertop Service

[Service]
Type=oneshot
ExecStart=/usr/bin/powertop --auto-tune

[Install]
WantedBy=multi-user.target
EOF

# Enable services
systemctl enable powertop.service	# power management
systemctl enable cpupower		# power management
systemctl enable lightdm.service	# login manager
systemctl enable NetworkManager.service	# network manager
systemctl enable openntpd.service	# network time

# Set systemd to ignore lid close and power button press
cat << EOF >> /etc/systemd/logind.conf
HandlePowerKey=ignore
HandleLidSwitch=ignore
EOF

# Add KMS module to loading modules
sed -i -e 's/MODULES=""/MODULES="i915"/g' /etc/mkinitcpio.conf

# generate Kernel image
mkinitcpio -p linux

# Install and customize GRUB
grub-install --target=i386-pc --recheck --debug $1
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=1/g' /etc/default/grub
#sed -i 's/quiet/modprobe.blacklist=ehci_pci tpm_tis.interrupts=0 i915.enable_ips=0/g' /etc/default/grub
sed -i 's/quiet/modprobe.blacklist=ehci_pci/g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# Create User
useradd -m -s /usr/bin/zsh $2

# Download settings
GITHUBPATH=https://raw.githubusercontent.com/DanielBilanovic/archc720/master
AUTOSTARTPATH=/home/$2/.config/autostart
XFCEPATH=/home/$2/.config/xfce4/xfconf/xfce-perchannel-xml/
cd /home/$2
mkdir -p $AUTOSTARTPATH
mkdir -p $XFCEPATH

wget $GITHUBPATH/xbindkeysrc
mv xbindkeysrc .xbindkeysrc

wget $GITHUBPATH/xbindkeys.desktop
mv xbindkeys.desktop $AUTOSTARTPATH/

wget $GITHUBPATH/compton.desktop
mv compton.desktop $AUTOSTARTPATH/

wget $GITHUBPATH/compton.conf
mv compton.conf $AUTOSTARTPATH/

wget $GITHUBPATH/xfce4-keyboard-shortcuts.xml
mv xfce4-keyboard-shortcuts.xml $XFCEPATH/

wget $GITHUBPATH/xfce4-panel.xml
mv xfce4-panel.xml $XFCEPATH/

wget $GITHUBPATH/xfce4-power-manager.xml
mv xfce4-power-manager.xml $XFCEPATH/

wget $GITHUBPATH/xfwm4.xml
mv xfwm4.xml $XFCEPATH/

wget $GITHUBPATH/zshrc
cp zshrc ~/.zshrc
mv zshrc .zshrc

wget https://raw.githubusercontent.com/DanielBilanovic/vim/master/vimrc
cp vimrc ~/.vimrc
mv vimrc .vimrc
chown -R $2:$2 /home/$2/

wget $GITHUBPATH/50-synaptics.conf
mv 50-synaptics.conf /etc/X11/xorg.conf.d/50-synaptics.conf

# Remove script file
rm ${0}

echo "CHANGE USER AND ROOT PASSWORD!"
exit

