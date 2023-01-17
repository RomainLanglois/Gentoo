#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No colors

script_github_path=https://raw.githubusercontent.com/RomainLanglois/Gentoo/main/Bash_Scripts/
scripts_array=(
	"00-Installation_part1_UEFI_Hardened.sh"
	"01-Installation_part2_UEFI_Hardened.sh"
	"02-Install_CLI_softwares.sh"
	"03-Install_Configure_Bwrap-Firewall-USB.sh"
	"04-Install_and_configure_secureBoot.sh"
	"05-Install_GUI_XORG.sh"
	"05-Install_GUI_Wayland-WIP.sh"
	"06-Update_Kernel.sh"
)
make_file=/mnt/gentoo/etc/portage/make.conf

/bin/echo "###########################################"
/bin/echo "[*] Formating and encrypting the designated disk"
/bin/lsblk
/bin/echo "[?] Please enter the disk to partition (ex: sda):"
read disk
/sbin/wipefs -a /dev/$disk
/usr/sbin/parted -a optimal /dev/$disk -s 'mklabel gpt' && \
/usr/sbin/parted -a optimal /dev/$disk -s 'unit mib' && \
/usr/sbin/parted -a optimal /dev/$disk -s 'mkpart primary fat32 1 515 ' && \
/usr/sbin/parted -a optimal /dev/$disk -s 'name 1 boot' && \
/usr/sbin/parted -a optimal /dev/$disk -s 'set 1 boot on' && \
/usr/sbin/parted -a optimal /dev/$disk -s 'mkpart primary 515 -1' && \
/usr/sbin/parted -a optimal /dev/$disk -s 'name 2 lvm' && \
/usr/sbin/parted -a optimal /dev/$disk -s 'set 2 lvm on' && \
/usr/sbin/parted -a optimal /dev/$disk -s 'print'

/bin/echo "###########################################"
/bin/echo "[*] Formating encrypting and mounting the luks partition"
/bin/lsblk
/sbin/modprobe dm-crypt
/bin/echo "[?] Please enter the partion to encrypt with luks (ex: sda2):"
read luks_partition
/sbin/cryptsetup luksFormat /dev/$luks_partition && \
/sbin/cryptsetup luksOpen /dev/$luks_partition lvm && \
/sbin/lvm pvcreate /dev/mapper/lvm && \
/sbin/vgcreate vg0 /dev/mapper/lvm && \
/sbin/lvcreate -L 40G -n root vg0 && \ 
/sbin/lvcreate -l 100%FREE -n home vg0 && \
/usr/sbin/mkfs.fat -F 32 /dev/$disk\1 && \
/sbin/mkfs.ext4 /dev/mapper/vg0-root && \
/sbin/mkfs.ext4 /dev/mapper/vg0-home && \ 
/bin/mount /dev/mapper/vg0-root /mnt/gentoo && \
/bin/mkdir /mnt/gentoo/home && \
/bin/mount /dev/mapper/vg0-home /mnt/gentoo/home && \
/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
/bin/echo "############################################"

/bin/echo "############################################"
/bin/echo "[*] Date configuration"
/bin/date
/bin/echo "[?] Please enter the current time (Example: 20:59:00):"
read date
/bin/date -s "$date" && \ 
/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
/bin/echo "############################################"

/bin/echo "############################################"
/bin/echo "[*] Downloading and decompressing Stage3 TarBall"
cd /mnt/gentoo && \
/usr/bin/links https://www.gentoo.org/downloads/mirrors/ && \
/bin/tar xpvf stage3-amd64-hardened-*.tar.xz --xattrs-include='*.*' --numeric-owner && \
/bin/rm -f stage3-amd64-hardened-*.tar.xz && \
/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
/bin/echo "############################################"

/bin/echo "############################################"
/bin/echo "[*] Setting-up make.conf"
/bin/echo "[?] Do you want to download a custom make.conf file from github ? (Y/N)"
read user_choice
if [[ $user_choice = "Y" ]]
then
	/bin/echo "[*] Going for a custom one !"
	/bin/rm -f /mnt/gentoo/etc/portage/make.conf && \
	cd /mnt/gentoo/etc/portage/ && \
	/usr/bin/wget https://raw.githubusercontent.com/RomainLanglois/Gentoo/main/Configuration_files/make.conf && \
	/bin/sed -i "s#MAKEOPTS=\"\"#MAKEOPTS=\"-j$(nproc)\"#g" $make_file && \
	cd /mnt/gentoo && \
	/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
	/bin/echo "############################################"
else
	/bin/echo "Going for a Generic one !"
	/bin/echo 'COMMON_FLAGS="-march=native -O2 -pipe"' >> $make_file && \
	/bin/echo 'GRUB_PLATFORMS="efi-64"' >> $make_file && \
	/bin/echo "MAKEOPTS=\"-j$(nproc)\"" >> $make_file && \
	/bin/echo 'USE="-systemd -ipv6"' >> $make_file && \
	/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
	/bin/echo "############################################"
fi

/bin/echo "############################################"
/bin/echo "[*] Configuring mirrors"
if [[ $user_choice = "N" ]]
then
	/usr/bin/mirrorselect -i -o >> $make_file
fi
/bin/mkdir --parents etc/portage/repos.conf && \
/bin/cp usr/share/portage/config/repos.conf etc/portage/repos.conf/gentoo.conf && \
/bin/cp --dereference /etc/resolv.conf etc/ && \
/bin/echo -e "${GREEN}[*] Done ! ${NC}" && \
/bin/echo "############################################"

/bin/echo "############################################"
/bin/echo "[*] Moving inside chroot !"
/bin/mount --types proc /proc /mnt/gentoo/proc && \
/bin/mount --rbind /sys /mnt/gentoo/sys && \
/bin/mount --make-rslave /mnt/gentoo/sys && \
/bin/mount --rbind /dev /mnt/gentoo/dev && \
/bin/mount --make-rslave /mnt/gentoo/dev && \
/bin/mount --bind /run /mnt/gentoo/run && \
/bin/mount --make-slave /mnt/gentoo/run
/bin/echo "[*] Downloading other installation scripts"
/bin/mkdir /mnt/gentoo/scripts
for script in ${scripts_array[@]}; do
	  /usr/bin/wget --quiet $script_github_path$script -O /mnt/gentoo/scripts/$script && \
	  /bin/chmod +x /mnt/gentoo/scripts/$script && \
	  /bin/echo -e "${GREEN}[*] Script: $script correctly downloaded and configured ! ${NC}"	
done
/bin/chmod -R 700 /mnt/gentoo/scripts && \
cd /mnt/gentoo/scripts && \
# chroot /mnt/gentoo /bin/bash 
/usr/bin/chroot /mnt/gentoo/ ./scripts/Installation_part2_UEFI_Hardened.sh
source /etc/profile && \
cd && \
/bin/umount /mnt/gentoo/home && \
/bin/umount -R /mnt/gentoo && \
/sbin/reboot
