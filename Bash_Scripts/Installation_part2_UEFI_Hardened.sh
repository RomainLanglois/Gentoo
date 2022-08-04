#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No colors

/bin/echo "########################################"
/bin/echo "[*] Preparing the environment and emerging @world"
source /etc/profile && \
export PS1="(chroot) ${PS1}" && \
/bin/mount $(/sbin/blkid | /bin/grep boot | /usr/bin/cut -d ":" -f1) /boot && \
/usr/bin/emerge-webrsync && \
/usr/bin/eselect profile list
/bin/echo "[?] Please select your profile:"
read profile
/usr/bin/eselect profile set $profile && \
/usr/bin/emerge --verbose --update --deep --newuse @world && \
/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Configuring timezone and locale"
/bin/echo "Europe/Paris" > /etc/timezone && \
/bin/echo "en_US ISO-8859-1" >> /etc/locale.gen && \
/bin/echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen && \
/bin/echo "fr_FR ISO-8859-1" >> /etc/locale.gen && \
/bin/echo "fr_FR.UTF-8 UTF-8" >> /etc/locale.gen && \
/usr/sbin/locale-gen
/usr/bin/eselect locale list
/bin/echo "[?] Please select your locale:"
read locale
/usr/bin/eselect locale set $locale && \
env-update && source /etc/profile && export PS1="(chroot) ${PS1}" && \
/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Configuring the keymap"
/bin/sed -i 's/keymap=\"us\"/keymap=\"fr\"/g' /etc/conf.d/keymaps && \
/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Installing / Configuring linux firmware, kernel sources and initramfs"
/bin/echo "sys-kernel/linux-firmware linux-fw-redistributable no-source-code" >> /etc/portage/package.license && \
/usr/bin/emerge -q sys-kernel/linux-firmware && \
/usr/bin/emerge -q sys-kernel/gentoo-sources && \
/usr/bin/emerge -q sys-fs/cryptsetup sys-fs/lvm2 && \
/usr/bin/emerge -q app-arch/lz4 && \
/usr/bin/eselect kernel list
/bin/echo "[?] Please select the kernel:"
read kernel
/usr/bin/eselect kernel set $kernel
cd /usr/src/linux
/bin/echo "[?] Do you want to create a generic kernel ? (Y/N)"
read user_choice
if [[ $user_choice = "Y" ]]
then
	/bin/echo "[*] Going for a generic kernel"
	/usr/bin/emerge -q sys-kernel/genkernel && \
	/usr/bin/genkernel --luks --lvm --no-zfs all && \
	/usr/bin/genkernel --luks --lvm --compress-initramfs-type=lz4 initramfs && \
	/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
	/bin/echo "########################################"
else
	/bin/echo "[*] Downloading custom kernel from github"
	/usr/bin/wget https://raw.githubusercontent.com/RomainLanglois/Gentoo/main/Configuration_files/kernel/initramfs -O /usr/src/linux/usr/initramfs_data.cpio && \
	/usr/bin/wget https://raw.githubusercontent.com/RomainLanglois/Gentoo/main/Configuration_files/kernel/config -O /usr/src/linux/.config && \
	cd /usr/src/linux && \
	/usr/bin/make -j$(nproc) && /usr/bin/make modules_install && /usr/bin/make install && \
	/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
	/bin/echo "########################################"
fi

/bin/echo "########################################" 
/bin/echo "[*] DHCP configuration:"
/usr/bin/emerge --noreplace --quiet net-misc/netifrc && \
/usr/bin/emerge -q net-misc/dhcpcd && \
for network_interface in $(/bin/ip a | /bin/grep -i up | /bin/grep -v lo | /usr/bin/cut -d ":" -f2 | sed 's/ //g'); do
	/bin/echo "config_$network_interface=dhcp" >> /etc/conf.d/net && \
	cd /etc/init.d && \
	/bin/ln -s net.lo "net.$network_interface" && \
	/sbin/rc-update add "net.$network_interface" default && \
	/bin/echo -e "${GREEN}[*] Configuration for $network_interface done ! ${NC}"
done
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Configuring /etc/fstab file"
/bin/echo "UUID=$(/sbin/blkid | /bin/grep boot | /usr/bin/cut -d "\"" -f2)            /boot           vfat            noauto,noatime  1 2" >> /etc/fstab && \
/bin/echo "UUID=$(/sbin/blkid | /bin/grep vg0-root | /usr/bin/cut -d "\"" -f2)       /               ext4            defaults        0 1" >> /etc/fstab && \
/bin/echo "UUID=$(/sbin/blkid | /bin/grep vg0-home | /usr/bin/cut -d "\"" -f2)       /home           ext4            defaults        0 1" >> /etc/fstab && \
/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Installing and configuring the bootloader"
/bin/echo "[?] Do you wand to use a EFI stub kernel as bootloader (Y/N) ?"
/bin/echo -e "${RED}[*] CAUTION ! Your kernel need to support EFI stub in order to boot without a bootloader like grub ${NC}"
/bin/echo -e "${RED}[*] CAUTION ! If your kernel needs an initramfs make sure it is harcoded inside the kernel ! Else it will not boot ! ${NC}"
read user_choice
if [[ $user_choice == "Y" ]]
then
	# Check if kernel is able to handle EFI stub, kernel initramfs and parameters are correctly configured
	if [[ $(grep -i "CONFIG_EFI=y" /usr/src/linux/.config) ]] && \
	   [[ $(grep -i "CONFIG_EFI_STUB=y" /usr/src/linux/.config) ]] && \
	   [[ $(grep -i 'CONFIG_INITRAMFS_SOURCE="/usr/src/linux/usr/initramfs_data.cpio"' /usr/src/linux/.config) ]] && \
	   [[ $(grep -i "CONFIG_CMDLINE_BOOL=y" /usr/src/linux/.config) ]] && \
	   [[ $(grep -i 'CONFIG_CMDLINE="root=/dev/mapper/vg0-root ro dolvm crypt_root=/dev/sda2 keymap=fr"' /usr/src/linux/.config) ]]
	then
		/bin/echo "########################################"
		/bin/echo "[*] Installing and configuring EFI stub"
		/usr/bin/emerge -q sys-boot/efibootmgr && \
		/bin/mkdir -p /boot/efi/gentoo /boot/efi/gentoo/rescue && \
		/bin/cp /usr/src/linux/arch/x86/boot/bzImage /boot/efi/gentoo/bzImage-$(uname -r).efi && \
		/bin/echo "[*] Generating a EFI stub rescue" && \
		/bin/cp /usr/src/linux/arch/x86/boot/bzImage /boot/efi/gentoo/rescue/bzImage-$(uname -r).efi && \
		/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
		/bin/echo "[*] Creating EFI stub entries" && \
		/usr/sbin/efibootmgr --create --disk /dev/sda --part 1 --label "Gentoo" --loader "\efi\gentoo\bzImage-$(uname -r).efi" && \
		/usr/sbin/efibootmgr --create --disk /dev/sda --part 1 --label "Gentoo_rescue" --loader "\efi\gentoo\rescue\bzImage-$(uname -r).efi" && \
		/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
		/bin/echo "########################################"
	else
		/bin/echo "[*] Your kernel is not compatible with a EFI stub and a harcoded initramfs, going for Grub !"
		/bin/echo "########################################"
		/bin/echo "[*] Installing and configuring Grub"
		/bin/rm -rf /etc/portage/package.use/ && \
		/bin/echo "sys-boot/grub:2 device-mapper" >> /etc/portage/package.use && \
		/usr/bin/emerge -q sys-boot/grub:2 && \
		luks_container=$(/sbin/blkid | /bin/grep -i luks | /usr/bin/cut -d " " -f 2) && \
		/bin/sed -i "s/\#GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"dolvm crypt_root=$luks_container keymap=fr\"/g" /etc/default/grub && \
		/usr/sbin/grub-install --target=x86_64-efi --efi-directory=/boot && \
		/usr/sbin/grub-mkconfig -o /boot/grub/grub.cfg && \
		/sbin/rc-update add lvm boot && \
		/sbin/rc-update add dmcrypt boot && \
		/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
		/bin/echo "########################################"
	fi
else
	/bin/echo "########################################"
	/bin/echo "[*] Installing and configuring Grub"
	/bin/rm -rf /etc/portage/package.use/ && \
	/bin/echo "sys-boot/grub:2 device-mapper" >> /etc/portage/package.use && \
	/usr/bin/emerge -q sys-boot/grub:2 && \
	luks_container=$(/sbin/blkid | /bin/grep -i luks | /usr/bin/cut -d " " -f 2) && \
	/bin/sed -i "s/\#GRUB_CMDLINE_LINUX=\"\"/GRUB_CMDLINE_LINUX=\"dolvm crypt_root=$luks_container keymap=fr\"/g" /etc/default/grub && \
	/usr/sbin/grub-install --target=x86_64-efi --efi-directory=/boot && \
	/usr/sbin/grub-mkconfig -o /boot/grub/grub.cfg && \
	/sbin/rc-update add lvm boot && \
	/sbin/rc-update add dmcrypt boot && \
	/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
	/bin/echo "########################################"
fi

/bin/echo "########################################"
/bin/echo "[*] Changing box name and adding/configuring a new user"
/bin/echo "[?] Please enter a name for the box:"
read box_name
/bin/sed -i "s/hostname=\"localhost\"/hostname=\'$box_name\'/g" /etc/conf.d/hostname && \
/usr/bin/emerge -q app-admin/sudo
/bin/echo "Please enter the username which will be used for this system:"
read username
/usr/sbin/useradd -m -G wheel -s /bin/bash $username && \
/usr/bin/passwd && \
/usr/bin/passwd $username && \
/bin/echo "%wheel ALL=(ALL:ALL) ALL" >> /etc/sudoers && \
/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Removing annoying beep sound"
/bin/sed -i "s#\# set bell-style none#set bell-style none#g" /etc/inputrc && \
/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Configuring clock"
/bin/date
/bin/echo "[?] Please enter the current time (Example : 20:59:00):"
read time
/bin/date -s "$time" && \
/sbin/hwclock --systohc && \
/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Installing auditd"
/usr/bin/emerge -q sys-process/audit && \
/sbin/rc-update add auditd default && \
/sbin/rc-service auditd start && \
/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Umounting the environment"
cd && \
/bin/umount $(/sbin/blkid | /bin/grep boot | /usr/bin/cut -d ":" -f1) && \
/bin/lsblk && \
/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
/bin/echo "########################################"
