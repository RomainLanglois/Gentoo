# This list is based on my current /var/lib/portage/world file
# Bash one liner to retrieve and format all packages inside the world file
# while read -r line; do echo "\"$line\""; done < /var/lib/portage/world

softwares_array=(
"app-admin/sudo"
"app-crypt/clevis"
"app-crypt/tpm2-tools"
"app-crypt/tpm2-tss"
"app-eselect/eselect-repository"
"app-misc/neofetch"
"app-portage/gentoolkit"
"app-xemacs/emerge"
"dev-vcs/git"
"net-misc/dhcpcd"
"net-misc/netifrc"
"sys-apps/usbutils"
"sys-boot/grub:2"
"sys-fs/cryptsetup"
"sys-fs/lvm2"
"sys-kernel/dracut"
"sys-kernel/gentoo-sources"
"sys-kernel/linux-firmware"
"sys-process/htop"
)

emaint -a sync
for software in ${softwares_array[@]}; do
  emerge -q $software
done
