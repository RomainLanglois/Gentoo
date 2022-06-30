#!/bin/bash
echo "########################################"
echo "Preparing the environment and emerging @world"
source /etc/profile
export PS1="(chroot) ${PS1}"
lsblk
echo "Please enter disk partition where to mount boot (ex: sda2):"
read boot_partition
mount /dev/$boot_partition /boot
emerge-webrsync
eselect profile list
echo "Please select your profile:"
read profile
eselect profile set $profile
rm -rf /etc/portage/package.use/
echo "dev-python/PyQt5 widgets gui" >> /etc/portage/package.use
emerge --verbose --update --deep --newuse @world 
echo "Done !"
echo "########################################"

echo "########################################"
echo "Configuring timezone and locale"
echo "Europe/Paris" > /etc/timezone
echo "en_US ISO-8859-1" >> /etc/locale.gen	
echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
echo "fr_FR ISO-8859-1" >> /etc/locale.gen
echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
eselect locale list
echo "Please select your locale:"
read locale
eselect locale set $locale
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
echo "Done !"
echo "########################################"

echo "########################################"
echo "Configuring the keymap"
sed -i 's/keymap=\"us\"/keymap=\"fr\"/g' /etc/conf.d/keymaps
echo "Done !"
echo "########################################"

echo "########################################"
echo "Installing / Configuring linux firmware, kernel sources and initramfs"
echo "sys-kernel/linux-firmware linux-fw-redistributable no-source-code" >> /etc/portage/package.license
emerge -q sys-kernel/linux-firmware
emerge -q sys-kernel/gentoo-sources
emerge -q sys-fs/cryptsetup sys-fs/lvm2
emerge -q app-arch/lz4
eselect kernel list
echo "Please select the kernel:"
read kernel
eselect kernel set $kernel
cd /usr/src/linux
echo "Do you want to create a generic kernel or download an already exiting one ? (Y/N)"
read user_choice
if [[ $user_choice = "Y" ]]
then
	emerge -q sys-kernel/genkernel
	genkernel --luks --lvm --no-zfs all
	genkernel --luks --lvm --compress-initramfs-type=lz4 initramfs
else
	cd /usr/src/linux
	wget https://raw.githubusercontent.com/RomainLanglois/Gentoo/main/Configuration_files/config_kernel_5-15-41.config
	mv config_kernel_*.config .config
	make -j$(nproc) && make modules_install && make install 
	emerge -q sys-kernel/genkernel
	genkernel --luks --lvm --kernel-config=/usr/src/linux/.config --compress-initramfs-type=lz4 initramfs
	
	# Dracut à finaliser lors de l'installation et configuration du TPM
	#emerge -q sys-kernel/dracut
	#echo "add_dracutmodules+=" lvm crypt "" >> /etc/dracut.conf
	#echo "use_fstab="yes"" >> /etc/dracut.conf
	## Trouver un moyen de compresser l'initramfs
	## -> Pas sur ci fonctionnel
	#echo "compress="lz4"" >> /etc/dracut.conf
	## ls /lib/modules/5.15.41-gentoo
	#dracut --kver $(uname -a | cut -f3 -d " ")	
fi
echo "Done !"
echo "########################################"

echo "########################################"
ip a
echo "DHCP configuration : please enter network interface:"
read network_interface
emerge --noreplace --quiet net-misc/netifrc
echo 'config_'$network_interface="dhcp" >> /etc/conf.d/net
emerge -q net-misc/dhcpcd
cd /etc/init.d
ln -s net.lo net.$network_interface
rc-update add net.$network_interface default
echo "Done !"
echo "########################################"

echo "########################################"
# A automatiser !
blkid
echo "Please enter UUID for /boot partition:"
read UUID_boot
echo "Please enter UUID LUKS for / partition (vg0-root):"
read UUID_luks_root
echo "Please enter UUID LUKS for /home partition (vg0-home):"
read UUID_luks_home
echo "UUID=$UUID_boot            /boot           vfat            noauto,noatime  1 2" >> /etc/fstab
echo "UUID=$UUID_luks_root       /               ext4            defaults        0 1" >> /etc/fstab
echo "UUID=$UUID_luks_home       /home           ext4            defaults        0 1" >> /etc/fstab
echo "Done !"
echo "########################################"

echo "########################################"
echo "Installing and configuring the bootloader (grub)"
echo "sys-boot/grub:2 device-mapper" >> /etc/portage/package.use
emerge -q sys-boot/grub:2
luks_container=$(blkid | grep -i luks | cut -d " " -f 2)
sed -i "s/\#GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"dolvm crypt_root=$luks_container keymap=fr\"/g" /etc/default/grub
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
rc-update add lvm boot
rc-update add dmcrypt boot
echo "Done !"
echo "########################################"

echo "########################################"
echo "Changing box name and adding/configuring a new user"
echo "Please enter a name for the box:"
read box_name
sed -i "s/hostname=\"localhost\"/hostname=\'$box_name\'/g" /etc/conf.d/hostname
emerge -q app-admin/sudo
echo "Please enter the username which will be used for this system:"
read username
useradd -m -G wheel -s /bin/bash $username
passwd
passwd $username
# A valider avec l'installation de SELinux
echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
echo "Done !"
echo "########################################"

echo "########################################"
echo "Configuring clock"
date
echo "Please : enter a time (Example : 20:59:00):"
read time
date -s "$time"
hwclock --systohc
echo "Done !"
echo "########################################"

echo "########################################"
echo "Installing auditd"
emerge -q sys-process/audit
/etc/init.d/auditd start
rc-update start auditd 
echo "Done !"
echo "########################################"

echo "########################################"
echo "Umounting the environment"
cd
umount /dev/$boot_partition
lsblk
echo "Done !"
echo "########################################"
echo "Execute the following line to end the instalaltion process and reboot:
source /etc/profile
cd
umount /mnt/gentoo/home
umount -R /mnt/gentoo
reboot
"
exit

