#!/bin/bash
make_file=/mnt/gentoo/etc/portage/make.conf

echo "###########################################"
echo "Formating and encrypting the designated disk"
lsblk
echo "Please enter the disk to partition (ex: sda):"
read disk
wipefs -a /dev/$disk

parted -a optimal /dev/$disk -s 'mklabel gpt'
parted -a optimal /dev/$disk -s 'unit mib'
parted -a optimal /dev/$disk -s 'mkpart primary 1 3' 
parted -a optimal /dev/$disk -s 'name 1 grub'
parted -a optimal /dev/$disk -s 'set 1 bios_grub on'
parted -a optimal /dev/$disk -s 'mkpart primary fat32 3 515 '
parted -a optimal /dev/$disk -s 'name 2 boot'
parted -a optimal /dev/$disk -s 'set 2 boot on'
parted -a optimal /dev/$disk -s 'mkpart primary 515 -1'
parted -a optimal /dev/$disk -s 'name 3 lvm'
parted -a optimal /dev/$disk -s 'set 3 lvm on'
parted -a optimal /dev/$disk -s 'print'

echo "###########################################"
echo "Formating encrypting and mounting the luks partition"
lsblk
modprobe dm-crypt
echo "Please enter the partion to encrypt with luks (ex: sda3):"
read luks_partition
cryptsetup luksFormat /dev/$luks_partition
cryptsetup luksOpen /dev/$luks_partition lvm 
lvm pvcreate /dev/mapper/lvm 
vgcreate vg0 /dev/mapper/lvm 
lvcreate -L 40G -n root vg0 
lvcreate -l 100%FREE -n home vg0
mkfs.fat -F 32 /dev/$disk\2
mkfs.ext4 /dev/mapper/vg0-root 
mkfs.ext4 /dev/mapper/vg0-home 
mount /dev/mapper/vg0-root /mnt/gentoo
mkdir /mnt/gentoo/home
mount /dev/mapper/vg0-home /mnt/gentoo/home
echo "Done !"
echo "############################################"

echo "############################################"
echo "Date configuration"
date
echo "Please : enter a date (Example : 13 JUN 2022 20:59:00):"
read date
date -s "$date"
echo "Done !"
echo "############################################"

echo "############################################"
echo "Downloading and decompressing Stage3 TarBall"
cd /mnt/gentoo
links https://www.gentoo.org/downloads/mirrors/
tar xpvf stage3-amd64-hardened-openrc-*.tar.xz --xattrs-include='*.*' --numeric-owner
rm -f stage3-amd64-hardened-openrc-*.tar.xz
echo "Done !"
echo "############################################"

echo "############################################"
echo "Setting-up make.conf"
# Pas clair echo à revoir !
echo "Do you want to download a custom make.conf file from gtihub ? (Y/N)"
read user_choice
if [[ $user_choice = "Y" ]]
then
	echo "Going for a custom one !"
	cd /mnt/gentoo/etc/portage/
	wget https://raw.githubusercontent.com/RomainLanglois/Gentoo/main/Configuration_files/make.conf
	sed -i "s#MAKEOPTS=\"\"#MAKEOPTS=\"-j$(nproc)\"#g" $make_file
	cd /mnt/gentoo
else
	echo "Going for a Generic one !"
	echo 'COMMON_FLAGS="-march=native -O2 -pipe"' >> $make_file
	echo 'GRUB_PLATFORMS="efi-64"' >> $make_file
	echo "MAKEOPTS=\"-j$(nproc)\"" >> $make_file
	echo 'USE="-systemd -ipv6"' >> $make_file
fi
echo "done !"
echo "############################################"

echo "############################################"
echo "Configuring mirrors"
if [[ $user_choice = "N" ]]
then
	mirrorselect -i -o >> $make_file
fi
mkdir --parents etc/portage/repos.conf
cp usr/share/portage/config/repos.conf etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf etc/
echo "done !"
echo "############################################"

echo "############################################"
echo "Moving inside the chroot !"
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run
chroot /mnt/gentoo /bin/bash
# Execute a script inside the chroot environnment (WIP - TODO: check if it works)
# mkdir /mnt/gentoo/script
# cd /mnt/gentoo/script
# wget https://raw.githubusercontent.com/RomainLanglois/Gentoo/main/Bash_Scripts/Installation_part2_UEFI_Hardened.sh
# chroot /mnt/gentoo/script ./Installation_part2_UEFI_Hardened.sh

