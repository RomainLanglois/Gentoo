#!/bin/bash

softwares_array=(
"app-eselect/eselect-repository"
"app-misc/neofetch"
"dev-vcs/git"
"sys-apps/usbutils"
"sys-process/htop"
"app-misc/ranger"
"app-editors/vim"
"app-shells/zsh"
"sys-fs/ntfs3g"
"dev-util/ltrace"
"dev-util/strace"
"app-arch/p7zip"
"sys-process/lsof"
"sys-apps/pciutils"
"sys-apps/hwdata"
"dev-python/pip"
"app-text/tree"
)

if [[ "$EUID" -ne 0 ]];
  then 
  /bin/echo "[*] Please run this script as root"
  exit 1
fi

/usr/sbin/emaint -a sync
for software in ${softwares_array[@]}; do
  /usr/bin/emerge -q $software
done
