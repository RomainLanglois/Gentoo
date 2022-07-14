#!/bin/bash

## Add support for the TPM
TPM_softwares_array=(
"app-crypt/clevis"
"app-crypt/tpm2-tools"
"app-crypt/tpm2-tss"
)

softwares_array=(
"app-eselect/eselect-repository"
"app-misc/neofetch"
"app-portage/gentoolkit"
"dev-vcs/git"
"sys-apps/usbutils"
"sys-process/htop"
"app-misc/ranger"
"app-editors/vim"
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

/bin/echo "[*] Do you wan to install the TPM packages ? (Y/N)"
read user_choice
if [[ $user_choice = "Y" ]];
then
	for TPM_software in ${TPM_softwares_array[@]}; do
	  /usr/bin/emerge -q $TPM_software
	done
else
	/bin/echo "[*] Exiting..."
fi
