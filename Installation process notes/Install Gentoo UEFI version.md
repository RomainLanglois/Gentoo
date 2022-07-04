# Install Gentoo (UEFI)
## Partitionning used (No Swap Partition)
```bash
/dev/sdX
|--> GRUB BIOS                       2   MB       no fs       GRUB loader itself
|--> /boot                 boot      512 MB       fat32       GRUB and kernel
|--> LUKS encrypted                  100%         encrypted   encrypted block device
     |-->  LVM             lvm       100%                  
           |--> /          root      40  GB       ext4        root filesystem
           |--> /home      home      100%         ext4        user files
```

## Before chroot 
### Start SSH service
```bash
/etc/init.d/sshd start
passwd
	The password must follow some complexity
	example : azerty123!
```

### Testing internet connection
```bash
ping 8.8.8.8
ping google.fr
sudo su
ls /sys/firmware/efi
```

### Detect what disk to install gentoo on
```bash
fdsik -l
```

### Partionning and creating the luks container
```bash
wipefs -a /dev/sdx
parted -a optimal /dev/sdx
        mklabel gpt
        unit mib
        mkpart primary 1 3 
        name 1 grub
        set 1 bios_grub on
        mkpart primary fat32 3 515 
        name 2 boot
	set 2 boot on
        mkpart primary 515 -1
        name 3 lvm
	set 3 lvm on
        print
        quit
lsblk
moprodbe dm-crypt
cryptsetup luksFormat /dev/sdX3 
cryptsetup luksOpen /dev/sdX3 lvm 
lvm pvcreate /dev/mapper/lvm 
vgcreate vg0 /dev/mapper/lvm 
lvcreate -L 25G -n root vg0 
lvcreate -l 100%FREE -n home vg0 
```

### Formatting
```bash
mkfs.fat -F 32 /dev/sdx2
mkfs.ext4 /dev/mapper/vg0-root 
mkfs.ext4 /dev/mapper/vg0-home 
```

### Mounting partition
```bash
mkdir /mnt/gentoo 
mount /dev/mapper/vg0-root /mnt/gentoo 
mkdir /mnt/gentoo/home 
mount /dev/mapper/vg0-home /mnt/gentoo/home/ 
```

## Configure the date
### Hardware clock
```bash
hwclock -r
```
### OS date
```bash
date
date -s "2 OCT 2006 18:00:00"
```

### Decompressing TarBall Stage3 (hardened one)
```bash
cd /mnt/gentoo
# Using terminal navigator
links https://www.gentoo.org/downloads/mirror/
# Wget directly the Stage3 Tarball
wget https://bouncer.gentoo.org/fetch/root/all/releases/amd64/autobuilds/20220522T170533Z/stage3-amd6$
tar xpvf stage3-amd64-hardened-openrc-*.tar.xz --xattrs-include='*.*' --numeric-owner
rm stage3-amd64-hardened-openrc-20220522T170533Z.tar.xz
```

### Configure make.conf
```bash
nano etc/portage/make.conf
	COMMON_FLAGS="-march=native -O2 -pipe"
	GRUB_PLATFORMS='efi-64'
	MAKEOPTS="-j4"
```

### Configure mirrors
```bash
mirrorselect -i -o >> /mnt/gentoo/etc/portage/make.conf
mkdir --parents etc/portage/repos.conf
cp usr/share/portage/config/repos.conf etc/portage/repos.conf/gentoo.conf
cp --dereference /etc/resolv.conf etc/
```

### Preparing for chroot
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
# Coffe break, it can take a long time
emerge --verbose --update --deep --newuse @world 
```

### Setting-up timezone
```bash
ls /usr/share/zoneinfo
```
#### Manual Way
```bash
echo "Europe/Paris" > /etc/timezone
```
#### Dynamic way
```bash
emerge --config sys-libs/timezone-data
```

### Setting-up locale
```bash
nano /etc/locale.gen
	en_US ISO-8859-1
	en_US.UTF-8 UTF-8
	fr_FR ISO-8859-1
	fr_FR.UTF-8 UTF-8
locale-gen
eselect locale list
eselect locale set 4
env-update && source /etc/profile && export PS1="(chroot) ${PS1}"
```

### Changing keyboard layout
```bash
nano /etc/conf.d/keymaps
	keymap="fr" 
```

### Adding a license
```bash
https://wiki.gentoo.org/wiki/etc/portage/package.license
#### folder where are stored the license
ls /var/db/repos/gentoo/licenses/
nano /etc/portage/package.license
	sys-kernel/linux-firmware linux-fw-redistributable no-source-code
```

### Install Linux firmware and kernel
```bash
emerge --ask sys-kernel/linux-firmware
emerge -q sys-kernel/gentoo-sources genkernel
mv /usr/src/linux<kernel_version> /usr/src/linux
emerge -q sys-fs/cryptsetup sys-fs/lvm2

(chroot) livecd /etc # vim genkernel.conf
...
LVM="yes"
...
LUKS="yes"
...
```

### Building Kernel and initramfs (Automatic way)
```bash
genkernel --luks --lvm --no-zfs all
genkernel --luks --lvm initramfs 
```

### Building Kernel and initramfs (Manual way)
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

### Configure the partion and their mounting point
```bash
blkid
nano /etc/fstab
	# https://wiki.gentoo.org/wiki/Handbook:AMD64/Full/Installation/fr#.C3.80_propos_de_fstab
	configure the /etc/fstab based on the previous UUID 
	# <fs>                                          <mountpoint>    <type>          <opts>          <dump/pass>
	UUID=DB1D-89C5                                  /boot           vfat            noauto,noatime  1 2
	UUID=6bedbbd8-cea9-4734-9c49-8e985c61c120       /               ext4            defaults        0 1
	UUID=5d6ff087-50ce-400f-91c4-e3378be23c00       /home           ext4            defaults        0 1
```

### Install the bootloader
```bash
emerge -q sys-boot/grub:2
echo "sys-boot/grub:2 device-mapper" >> /etc/portage/package.use/sys-boot
```
 
### Configure grub to boot using luks
```bash
blkid | grep -i luks
nano /etc/default/grub
	GRUB_CMDLINE_LINUX="dolvm crypt_root=UUID=(REPLACE ME WITH sdb3 UUID from above) root=/dev/mapper/vgO-root"
echo 'GRUB_PLATFORMS="efi-64"' >> /etc/portage/make.conf
grub-install --target=x86_64-efi --efi-directory=/boot
grub-mkconfig -o /boot/grub/grub.cfg
rc-update add lvm boot # -> Not sure for 'default' parameter 
```

### Configure hostname and add a new user (home folder should be created)
```bash
nano /etc/conf.d/hostname
	hostname='GentooBox' -> MachineName
emerge -q app-admin/sudo
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

