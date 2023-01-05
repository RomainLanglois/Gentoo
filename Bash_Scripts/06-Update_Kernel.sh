#!/bin/bash

# Still TODO in Phase 7 !
	# 1) /usr/sbin/efibootmgr -b 0004 -B
	# 2) rm /boot/efi/gentoo/old_kernel

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No colors
current_kernel_version=$(/usr/bin/eselect kernel list | /bin/grep "*" | /bin/grep "linux-" | /bin/cut -d " " -f6)

if [[ "$EUID" -ne 0 ]];
  then 
  /bin/echo "[*] Please run this script as root"
  exit 1
fi

/bin/echo "########################################"
/bin/echo "[*] Step 1: Emerging the @world variable"
/usr/bin/emerge --ask --update --deep --with-bdeps=y --newuse @world && \
/bin/echo -e "${GREEN}[*] Step 1 done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Step 2: Setting symlink to new kernel sources"
/usr/bin/eselect kernel list
/bin/echo -e "[?] Please select the new kernel version you need (e.g: 2)"
read eselect_kernel_number
/usr/bin/eselect kernel set $eselect_kernel_number
/bin/echo "[*] Checking if the chosen kernel version is right"
/usr/bin/eselect kernel list
/bin/echo -e "[?] Is the kernel version right (Y/N)"
read user_choice
if [[ ! $user_choice == "Y" ]];
then
	/bin/echo "${RED}[*] Error while selecting the kernel version. Exiting the script...${NC}" && \
	exit 1
fi
/bin/echo -e "${GREEN}[*] Step 2 done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Step 3: Moving to the new kernel folder"
cd /usr/src/linux && \
/bin/echo -e "${GREEN}[*] Step 3 done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Step 4: Adjusting the .config file for the new kernel"
/bin/cp /usr/src/$current_kernel_version/.config /usr/src/linux/ && \
/bin/echo "[?] Whar do you want to do ? (e.g: 1)"
/bin/echo "		[1] make oldconfig 		<-- The user is asked for a decision"
/bin/echo "		[2] make olddefconfig 	<-- Keep all of the options from the old .config and set the new options to their recommended default values"
/bin/echo "		[3] make menuconfig 	<-- Remake a new config file from scratch"
read user_choice
if [[ "$user_choice" == "1" ]]
then
	/usr/bin/make oldconfig
elif [[ "$user_choice" == "2" ]]
then
	/usr/bin/make olddefconfig
else
	/usr/bin/make mrproper && /usr/bin/make menuconfig
fi
/bin/echo -e "${GREEN}[*] Step 4 done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Step 5: Building the new kernel"
if [[ ! $(/bin/lsblk | /bin/grep -i boot) ]]
then
	/bin/echo "[*] The boot partiton is not mounted !, mounting it..." && \
	/bin/mount $(/sbin/blkid | /bin/grep -i boot | /bin/cut -d ":" -f1) /boot && \
	/bin/echo -e "${GREEN}[*] Done !${NC}"
fi
/bin/cp /usr/src/$current_kernel_version/usr/initramfs_data.cpio /usr/src/linux/usr/ && \
/usr/bin/make -j$(nproc) && /usr/bin/make modules_install && /usr/bin/make install && \
/usr/bin/genkernel --luks --lvm --kernel-config=/usr/src/linux/.config --no-compress-initramfs initramfs && \
/bin/mv /boot/initramfs-*.img /usr/src/linux/usr/initramfs_data.cpio && \
/usr/bin/make -j$(nproc) && /usr/bin/make modules_install && /usr/bin/make install
/bin/echo -e "${GREEN}[*] Step 5 done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Step 6: Updating the bootloader"
new_kernel_version=$(/usr/bin/eselect kernel list | /bin/grep "*" | /bin/grep "linux-" | /bin/cut -d " " -f6) && \
/bin/cp /usr/src/linux/arch/x86/boot/bzImage /boot/efi/gentoo/bzImage-$new_kernel_version.efi && \
/usr/sbin/efibootmgr --create --disk /dev/sda --part 1 --label "$new_kernel_version" --loader "\efi\gentoo\bzImage-$new_kernel_version.efi" && \
/bin/echo -e "${GREEN}[*] Step 6 done ! ${NC}" && \
/bin/echo "########################################"

/bin/echo "########################################"
/bin/echo "[*] Step 7: Removing old kernel files and configuration"
/bin/rm /boot/config-$(uname -r) /boot/System.map-$(uname -r) /boot/vmlinuz-$(uname -r) && \
/bin/echo "[?] do you need to remove an old kernel ? (Y/N)"
read user_choice
if [[ $user_choice == "Y" ]]
then
	/bin/echo "[?] Which kernel do you want to remove ? [e.g. 1]" && \
	/usr/bin/eselect kernel list && \
	read user_choice && \
	/bin/rm -r /usr/src/$(eselect kernel list | grep "\[$user_choice\]" | /bin/cut -d " " -f6) && \
	/bin/rm -r /lib/modules/$(eselect kernel list | grep "\[$user_choice\]" | /bin/cut -d " " -f6 | cut -d "-" -f2)-gentoo-x86_64
else
	/bin/echo "${GREEN}[*] No old kernel files removed !${NC}"
fi
/bin/echo -e "${GREEN}[*] Step 7 done ! ${NC}" && \
/bin/echo "########################################"
