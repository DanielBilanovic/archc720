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
cat << EOF >> /etc/systemd/system/powertop.service
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

# Create User
useradd -m -s /usr/bin/zsh $2

# Change xfce4 settings for power management
# Ask when power button is pressed
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/power-button-action -s 3
# Suspend when lid is closed (ac and battery)
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-ac -s 1
xfconf-query -c xfce4-power-manager -p /xfce4-power-manager/lid-action-on-battery -s 1

# Enable login manager at boot
systemctl enable lightdm.service
echo "greeter-setup-script=/usr/bin/numlockx on" >> /etc/lightdm/lightdm.conf

# Download settings
mkdir -p /home/$2/.config/autostart/
chown -R $2:$2 /home/$2/.config

wget https://raw.githubusercontent.com/DanielBilanovic/archc720/master/xbindkeysrc
mv xbindkeysrc /home/$2/.xbindkeysrc
chown $2:$2 /home/$2/.xbindkeysrc

wget https://raw.githubusercontent.com/DanielBilanovic/archc720/master/xbindkeys.desktop
mv xbindkeys.desktop /home/$2/.config/autostart/xbindkeys.desktop
chown $2:$2 /home/$2/.config/autostart/xbindkeys.desktop

wget https://raw.githubusercontent.com/DanielBilanovic/archc720/master/compton.desktop
mv compton.desktop /home/$2/.config/autostart/compton.desktop
chown $2:$2 /home/$2/.config/autostart/compton.desktop

wget https://raw.githubusercontent.com/DanielBilanovic/archc720/master/compton.conf
mv compton.conf /home/$2/.config/autostart/compton.conf
chown $2:$2 /home/$2/.config/autostart/compton.conf

wget https://raw.githubusercontent.com/DanielBilanovic/archc720/master/zshrc
cp zshrc ~/.zshrc
mv zshrc /home/$2/.zshrc
chown $2:$2 /home/$2/.zshrc

wget https://raw.githubusercontent.com/DanielBilanovic/vim/master/vimrc
cp vimrc ~/.vimrc
mv vimrc /home/$2/.vimrc
chown $2:$2 /home/$2/.vimrc

wget https://raw.githubusercontent.com/DanielBilanovic/archc720/master/50-synaptics.conf
mv 50-synaptics.conf /etc/X11/xorg.conf.d/50-synaptics.conf

# Remove script file
rm ${0}

echo "CHANGE USER AND ROOT PASSWORD!"
exit
