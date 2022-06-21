# Install Gentoo (BIOS)
## Before chroot
### Start SSH service
```bash
/etc/init.d/sshd start
passwd
	- The password must follow some complexity
	- example : azerty123!
```
### Testing internet connection
```bash
ping 8.8.8.8
ping google.fr
sudo su
```
### Detect what disk to install gentoo on
```bash
fdsik -l
```
### Partionning and formatting the targeted disk
```bash
wipefs -a /dev/sdx
parted -a optimal /dev/sdx
        mklabel gpt
        unit mib
        mkpart primary 1 3 
        name 1 grub
        set 1 bios_grub on
        mkpart primary 3 131
        name 2 boot
        mkpart primary 131 4227
        name 3 swap
        mkpart primary 4227 -1
        name 4 rootfs
        print
        quit
lsblk
mkfs.fat -F 32 /dev/sdx2
mkfs.ext4 /dev/sdx4
mkswap /dev/sdx3
swapon /dev/sdx3
mount /dev/sdx4 /mnt/gentoo
```
### Configure the date
#### Hardware clock
```bash
hwclock -r
```
#### OS date
```bash
date 
date -s "2 OCT 2006 18:00:00"
```

### Wget stage3 tarball (hardened one) 
```bash
wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20220522T170533Z/stage3-amd6$
tar xpvf stage3-amd64-hardened-openrc-20220522T170533Z.tar.xz --xattrs-include='*.*' --numeric-owner
rm stage3-amd64-hardened-openrc-20220522T170533Z.tar.xz
```

### Configuring make.conf
```bash
nano /etc/portage/make.conf
	COMMON_FLAGS="-march=native -O2 -pipe"
	MAKEOPTS="-j${number_of_CPU}"
```

### Configuring mirrors
```bash
mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
mkdir --parents etc/portage/repos.conf
cp usr/share/portage/config/repos.conf etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf etc/
```

### Chroot
```bash
mount --types proc /proc /mnt/gentoo/proc
mount --rbind /sys /mnt/gentoo/sys
mount --make-rslave /mnt/gentoo/sys
mount --rbind /dev /mnt/gentoo/dev
mount --make-rslave /mnt/gentoo/dev
mount --bind /run /mnt/gentoo/run
mount --make-slave /mnt/gentoo/run 
chroot /mnt/gentoo /bin/bash
source /etc/profile
export PS1="(chroot) ${PS1}"
```
## Inside chroot
```bash
mount /dev/sdx2 /boot
emerge-webrsync
eselect profile list
# Emerging the @world variable is a pretty long process
emerge --verbose --update --deep --newuse @world  
```

### Setting-up timezone and locale
```bash
# Configure timezone
ls /usr/share/zoneinfo
## Manual Way
echo "Europe/Paris" > /etc/timezone
## Dynamic way
emerge --config sys-libs/timezone-data

# Configure system language
nano /etc/locale.gen
	en_US ISO-8859-1
	en_US.UTF-8 UTF-8
	fr_FR ISO-8859-1
	fr_FR.UTF-8 UTF-8
locale-gen
eselect locale list
eselect locale set 4
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"

# Will change the keyboard layout only in the tty
nano /etc/conf.d/keymaps
	keymap="fr" 
```

### Configuring licenses
```bash
https://wiki.gentoo.org/wiki//etc/portage/package.license
#### folder where are stored the license
ls /var/db/repos/gentoo/licenses/
nano /etc/portage/package.license
	sys-kernel/linux-firmware linux-fw-redistributable no-source-code
```

### Install firmware and linux kernel sources
```bash
emerge --ask sys-kernel/linux-firmware
emerge -q sys-kernel/gentoo-sources genkernel
```

### Install a compression software (kernel compression optimization)
```bash
emerge -q app-arch/lzop app-arch/lz4
```

### Kernel configuration (Automatic way)
```bash
genkernel all
```

### Kernel configuration (Manual way)
```bash
mv /usr/srv/linux<something> /usr/srv/linux
cd /usr/src/linux
make menuconfig
make && make modules_install && make install
genkernel --install --kernel-config=/usr/src/linux/.config initramfs
ls /boot/initramfs*
```

### Network configuration (DHCP)
```bash
emerge --noreplace --quiet net-misc/netifrc
nano /etc/conf.d/net
	config_eth0="dhcp"
emerge -q net-misc/dhcpcd
cd /etc/init.d
ln -s net.lo net.eth0
rc-update add net.eth0 default
```

### Configure /etc/fstab file
```bash
blkid -s UUID -o value /dev/sdx2
blkid -s UUID -o value /dev/sdx3
blkid -s UUID -o value /dev/sdx4
nano /etc/fstab
# configure the /etc/fstab based on the previous UUID 
	/dev/sda1   /boot        ext2    defaults,noatime     0 2
	/dev/sda2   none         swap    sw                   0 0
	/dev/sda3   /            ext4    noatime              0 1
```
More details on /etc/fstab file here :
- https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation/fr#.C3.80_propos_de_fstab

### Install the bootloader
```bash
emerge -q sys-boot/grub:2
grub-install /dev/sda
grub-mkconfig -o /boot/grub/grub.cfg
```

### Install sudo
```bash
emerge -q app-admin/sudo
```

# Configure hostname and add a new user (home folder should be created)
```bash
nano /etc/conf.d/hostname
	hostname='GentooBox' -> MachineName
useradd -m -G users,wheel,audio -s /bin/bash <username>
passwd
passwd <username>
```

### Umount and reboot 
```bash
lsblk
umount /dev/sdx2
swapoff /dev/sdx3
exit
source /etc/profile
umount -R /mnt/gentoo
lsblk
reboot
```




