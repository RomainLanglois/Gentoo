#!/bin/bash
/bin/echo "########################################"
/bin/echo "Preparing the environment and emerging @world"
source /etc/profile
export PS1="(chroot) ${PS1}"
/bin/lsblk
/bin/echo "Please enter disk partition where to mount boot (ex: sda2):"
read boot_partition
/bin/mount /dev/$boot_partition /boot
/usr/bin/emerge-webrsync
/usr/bin/eselect profile list
/bin/echo "Please select your profile:"
read profile
/usr/bin/eselect profile set $profile
/usr/bin/emerge --verbose --update --deep --newuse @world
/bin/echo "Done !"
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "Configuring timezone and locale"
/bin/echo "Europe/Paris" > /etc/timezone
/bin/echo "en_US ISO-8859-1" >> /etc/locale.gen
/bin/echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen
/bin/echo "fr_FR ISO-8859-1" >> /etc/locale.gen
/bin/echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen
/usr/sbin/locale-gen
/usr/bin/eselect locale list
/bin/echo "Please select your locale:"
read locale
/usr/bin/eselect locale set $locale
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
/bin/echo "Done !"
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "Configuring the keymap"
/bin/sed -i 's/keymap=\"us\"/keymap=\"fr\"/g' /etc/conf.d/keymaps
/bin/echo "Done !"
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "Installing / Configuring linux firmware, kernel sources and initramfs"
/bin/echo "sys-kernel/linux-firmware linux-fw-redistributable no-source-code" >> /etc/portage/package.license
/usr/bin/emerge -q sys-kernel/linux-firmware
/usr/bin/emerge -q sys-kernel/gentoo-sources
/usr/bin/emerge -q sys-fs/cryptsetup sys-fs/lvm2
/usr/bin/emerge -q app-arch/lz4
/usr/bin/eselect kernel list
/bin/echo "Please select the kernel:"
read kernel
/usr/bin/eselect kernel set $kernel
cd /usr/src/linux
/bin/echo "Do you want to create a generic kernel ? (Y/N)"
read user_choice
if [[ $user_choice = "Y" ]]
then
	/usr/bin/emerge -q sys-kernel/genkernel
	/usr/bin/genkernel --luks --lvm --no-zfs all
	/usr/bin/genkernel --luks --lvm --compress-initramfs-type=lz4 initramfs
else
	cd /usr/src/linux
	make menuconfig
	#/usr/bin/wget https://raw.githubusercontent.com/RomainLanglois/Gentoo/main/Configuration_files/config_kernel_5-15-41.config
	#/bin/mv config_kernel_*.config .config
	make -j$(nproc) && make modules_install && make install
	/usr/bin/emerge -q sys-kernel/genkernel
	/usr/bin/genkernel --luks --lvm --kernel-config=/usr/src/linux/.config --compress-initramfs-type=lz4 initramfs

	# Dra/usr/bin/cut à finaliser lors de l'installation et configuration du TPM
	#/usr/bin/emerge -q sys-kernel/dracut
	#/bin/echo "add_dra/usr/bin/cutmodules+=" lvm crypt "" >> /etc/dracut.conf
	#/bin/echo "use_fstab="yes"" >> /etc/dracut.conf
	## Trouver un moyen de compresser l'initramfs
	## -> Pas sur si fonctionnel
	#/bin/echo "compress="lz4"" >> /etc/dracut.conf
	## ls /lib/modules/5.15.41-gentoo
	#dracut --kver $(uname -a | /usr/bin/cut -f3 -d " ")
fi
/bin/echo "Done !"
/bin/echo "########################################"

/bin/echo "########################################" 
/bin/echo "DHCP configuration:"
network_interface=$(/bin/ip a | /bin/grep -i up | /bin/grep -v lo | /usr/bin/cut -d ":" -f2 | sed 's/ //g')
/usr/bin/emerge --noreplace --quiet net-misc/netifrc
/bin/echo "config_$network_interface=dhcp" >> /etc/conf.d/net
/usr/bin/emerge -q net-misc/dhcpcd
cd /etc/init.d
/bin/ln -s net.lo "net.$network_interface"
/sbin/rc-update add "net.$network_interface" default
/bin/echo "Done !"
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "Configuring /etc/fstab file"
/bin/echo "UUID=$(/sbin/blkid | /bin/grep boot | /usr/bin/cut -d "\"" -f2)            /boot           vfat            noauto,noatime  1 2" >> /etc/fstab
/bin/echo "UUID=$(/sbin/blkid | /bin/grep vg0-root | /usr/bin/cut -d "\"" -f2)       /               ext4            defaults        0 1" >> /etc/fstab
/bin/echo "UUID=$(/sbin/blkid | /bin/grep vg0-home | /usr/bin/cut -d "\"" -f2)       /home           ext4            defaults        0 1" >> /etc/fstab
/bin/echo "Done !"
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "Installing and configuring the bootloader (grub)"
/bin/rm -rf /etc/portage/package.use/
/bin/echo "sys-boot/grub:2 device-mapper" >> /etc/portage/package.use
/usr/bin/emerge -q sys-boot/grub:2
luks_container=$(/sbin/blkid | /bin/grep -i luks | /usr/bin/cut -d " " -f 2)
/bin/sed -i "s/\#GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"dolvm crypt_root=$luks_container keymap=fr\"/g" /etc/default/grub
/usr/sbin/grub-install --target=x86_64-efi --efi-directory=/boot
/usr/sbin/grub-mkconfig -o /boot/grub/grub.cfg
/sbin/rc-update add lvm boot
/sbin/rc-update add dmcrypt boot
/bin/echo "Done !"
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "Changing box name and adding/configuring a new user"
/bin/echo "Please enter a name for the box:"
read box_name
/bin/sed -i "s/hostname=\"localhost\"/hostname=\'$box_name\'/g" /etc/conf.d/hostname
/usr/bin/emerge -q app-admin/sudo
/bin/echo "Please enter the username which will be used for this system:"
read username
/usr/sbin/useradd -m -G wheel -s /bin/bash $username
/usr/bin/passwd
/usr/bin/passwd $username
/bin/echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers
/bin/echo "Done !"
/bin/echo "########################################"

# TODO à automatiser ! (peut être retirer la partie de modification de la date déjà fait auparavant)
/bin/echo "########################################"
/bin/echo "Configuring clock"
/bin/date
/bin/echo "Please : enter the current time (Example : 20:59:00):"
read time
/bin/date -s "$time"
/sbin/hwclock --systohc
/bin/echo "Done !"
/bin/echo "########################################"
# TODO

/bin/echo "########################################"
/bin/echo "Installing auditd"
/usr/bin/emerge -q sys-process/audit
/sbin/rc-update add auditd default
/sbin/rc-service auditd start
/bin/echo "Done !"
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "Umounting the environment"
cd
/bin/umount /dev/$boot_partition
/bin/lsblk
/bin/echo "Done !"
/bin/echo "########################################"
/bin/echo "Execute the following line to end the instalaltion process and reboot:
source /etc/profile
cd
/bin/umount /mnt/gentoo/home
/bin/umount -R /mnt/gentoo
/sbin/reboot
"
exit
