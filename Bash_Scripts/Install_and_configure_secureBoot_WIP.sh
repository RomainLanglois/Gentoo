#!/bin/bash

# TODO
	# Définir les éléments à signer afin de faire correctement booter l'OS
		# Stub Kernel ?

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No colors

if [[ "$EUID" -ne 0 ]];
then
  /bin/echo -e "${RED}[*] Please run this script as root ${NC}"
  exit 1
fi

program_array=(
	"app-crypt/efitools"
	"app-crypt/sbsigntools"
	"dev-libs/openssl"
)

# Check if program is installed, if not install it
for program in ${program_array[@]}; do
	if [[ emerge -p $program | grep -i "ebuild  N" ]]
	then
		emerge -q $program
	fi
done

efikeys_folder=/etc/efikeys
check_if_system_has_rebooted=/root/.reboot_needed

if [[ ! -f $check_if_system_has_rebooted ]]
then
	/bin/echo "[*] Entering phase 1 !"
	/bin/echo "[*] Create directory and backup old PK, KEK, db and dbx variables"
	if [[ ! -d $efikeys_folder ]]
	then
		/bin/mkdir -p -v $efikeys_folder
	fi
	/bin/chmod 700 $efikeys_folder && \
	cd $efikeys_folder && \
	/usr/bin/efi-readvar -v PK -o old_PK.esl && \
	/usr/bin/efi-readvar -v KEK -o old_KEK.esl && \
	/usr/bin/efi-readvar -v db -o old_db.esl && \
	/usr/bin/efi-readvar -v dbx -o old_dbx.esl && \
	/bin/echo -e "${GREEN}[*] Done !${NC}"

	/bin/echo "[*] Generate keys (private and public), their respective certificate and configure the correct rights on them"
	/bin/echo -n "Enter a Common Name to embed in the keys: "
	read name
	/usr/bin/openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$name PK/" -keyout PK.key -out PK.crt -days 3650 -nodes -sha256 && \
	/usr/bin/openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$name KEK/" -keyout KEK.key -out KEK.crt -days 3650 -nodes -sha256 && \
	/usr/bin/openssl req -new -x509 -newkey rsa:2048 -subj "/CN=$name db/" -keyout db.key -out db.crt -days 3650 -nodes -sha256 && \
	/bin/chmod -v 400 *.key && \
	/bin/echo -e "${GREEN}[*] Done !${NC}"

	/bin/echo "[*] Preparing Keystore Update Files from Keys"
	# 'signed signature list' (aka '.auth')
	# efi-updatevar will only accept it in this format.
	# First, we make a signature list (which requires a unique ID, the value of which is essentially unimportant), and then we use our own (private) platform key to sign it
	# cert-to-efi-sig-list - tool for converting openssl certificates to EFI signature lists
	# sign-efi-sig-list - signing tool for secure variables as EFI Signature Lists
	/usr/bin/cert-to-efi-sig-list -g "$(uuidgen)" PK.crt PK.esl && \
	/usr/bin/cert-to-efi-sig-list -g "$(uuidgen)" KEK.crt KEK.esl && \
	/usr/bin/cert-to-efi-sig-list -g "$(uuidgen)" db.crt db.esl && \
	/usr/bin/sign-efi-sig-list -k PK.key -c PK.crt PK PK.esl PK.auth && \
	/usr/bin/sign-efi-sig-list -a -k PK.key -c PK.crt KEK KEK.esl KEK.auth && \
	/usr/bin/sign-efi-sig-list -a -k KEK.key -c KEK.crt db db.esl db.auth && \
	/usr/bin/sign-efi-sig-list -k KEK.key -c KEK.crt dbx old_dbx.esl old_dbx.auth && \
	/bin/echo -e "${GREEN}[*] Done !${NC}"

	/bin/echo "[*] Convert x509 certificat to DER format"
	/usr/bin/openssl x509 -outform DER -in PK.crt -out PK.cer && \
	/usr/bin/openssl x509 -outform DER -in KEK.crt -out KEK.cer && \
	/usr/bin/openssl x509 -outform DER -in db.crt -out db.cer && \
	/bin/echo -e "${GREEN}[*] Done !${NC}"

	/bin/echo "[*] Merging EFI keys and signing them"
	# Compound de la PK ??
	#cat old_PK.esl PK.esl > compound_PK.esl
	cat old_KEK.esl KEK.esl > compound_KEK.esl && \
	cat old_db.esl db.esl > compound_db.esl && \
	/usr/bin/sign-efi-sig-list -k PK.key -c PK.crt KEK compound_KEK.esl compound_KEK.auth && \
	/usr/bin/sign-efi-sig-list -k KEK.key -c KEK.crt db compound_db.esl compound_db.auth && \
	/bin/echo -e "${GREEN}[*] Done !${NC}"

	# clear the UEFI secure boot variables, thereby entering setup mode; and
	# restart your machine (saving changes).
	/bin/echo "[*] You will need to reboot your system to modify UEFI parameters related to secure boot"
	/bin/echo "secureboot -> OFF"
	/bin/echo "secureboot -> setup mode"
	/bin/echo "secureboot -> clean secureboot keys"
	/bin/echo "[?] are you ready to restart (Y/N) ?"
	read user_choice
	if [[ $user_choice == "Y" ]]
	then
		/bin/echo "[*] Your system will restart in 5 seconds"
		/usr/bin/touch $check_if_system_has_rebooted
		/usr/bin/sleep 5
		/sbin/reboot
	else
		/bin/echo "[*] the user is not ready to restart"
		exit 0
	fi

elif [[ -f $check_if_system_has_rebooted ]]
then
	/bin/echo "[*] Entering phase 2 !"
	/bin/echo "[*] Update EFI variables for secureboot"
	cd $efikeys_folder
	# The -e option specifies that an EFI signature list file is to be loaded (and the -f option precedes the filename itself).
	# Because we are in setup mode, no private key is required for these operations (which it would be, if we were in user mode).
	/usr/bin/efi-updatevar -e -f old_dbx.esl dbx
	/usr/bin/efi-updatevar -e -f compound_db.esl db
	/usr/bin/efi-updatevar -e -f compound_KEK.esl KEK
	/usr/bin/efi-updatevar -f PK.auth PK
	/usr/bin/efi-readvar
	/bin/echo "[?] Please check the content of the different EFI variables, is everyting correct ? (Y/N)"
	read user_choice
	if [[ ! $user_choice == "Y" ]]
	then
		/bin/echo -e "${RED}[*] Something wrong happened, exiting... ${NC}"
		exit 1
	fi

	/bin/echo "[*] backup new efi variables"
	/usr/bin/efi-readvar -v PK -o new_pk.esl
	/usr/bin/efi-readvar -v KEK -o new_kek.esl
	/usr/bin/efi-readvar -v db -o new_db.esl
	/usr/bin/efi-readvar -v dbx -o new_dbx.esl
	/bin/echo -e "${GREEN}[*] Done !${NC}"

	/bin/echo "[*] Signing process"
	if [[ ! $(lsblk | /bin/grep -i boot) ]]
	then
		/bin/mount $(/sbin/blkid | /bin/grep -i boot | /usr/bin/cut -d ":" -f1) /boot
	fi
	# Sign kernel
	kernel_image=$(ls /boot | /bin/grep -i vmlinuz)
	cd /boot
	cp $kernel_image $kernel_image-unsigned
	/usr/bin/sbsign --key /etc/efikeys/db.key --cert /etc/efikeys/db.crt $kernel_image-unsigned --output $kernel_image

	# Sign grub bootloader
	# Image was already signed; adding additional signature
	# Peut être nécessaire de refaire un kernel
	efi_application=/boot/EFI/gentoo/grubx64.efi
	cp $efi_application $efi_application-unsigned
	/usr/bin/sbsign --key /etc/efikeys/db.key --cert /etc/efikeys/db.crt $efi_application-unsigned --output $efi_application

	# Impossible to sign initramfs with sbsigntools
		# Utiliser GPG
		# Caution, this command return .old initramfs too
		# PB invalid DOS header
		# Est-il possible de signer ce fichier ?
	#initramfs_file=$(ls /boot | grep -i initramfs)
	#cp $initramfs_file $initramfs_file-unsigned
	#sbsign --key /etc/efikeys/db.key --cert /etc/efikeys/db.crt $initramfs_file-unsigned --output $initramfs_file

	# PB invalid DOS header
		# utiliser GPG ?
		# Est-il possible de signer ce fichier ?
	#grub_config_file=/boot/grub/grub.cfg
	#cp $grub_config_file $grub_config_file-unsigned
	#sbsign --key /etc/efikeys/db.key --cert /etc/efikeys/db.crt $grub_config_file-unsigned --output $grub_config_file
	

    	/bin/echo "[*] You will need to reboot your system to modify UEFI parameters related to secure boot"
        /bin/echo "secureboot -> ON"
        /bin/echo "secureboot -> user mode"
        /bin/echo "[?] are you ready to restart (Y/N) ?"
        read user_choice
        if [[ $user_choice == "Y" ]]
        then
            	/bin/echo "[*] Your system will restart in 5 seconds"
                /bin/rm $check_if_system_has_rebooted
                /usr/bin/sleep 5
                /sbin/reboot
        else
            	/bin/echo -e "${RED}[*] the user is not ready to restart ${NC}"
                exit 0
        fi
else
	/bin/echo -e "${RED}[*] Something wrong happened... ${NC}"
	exit 1
fi
