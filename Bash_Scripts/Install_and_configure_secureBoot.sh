#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No colors
efikeys_folder=/etc/efikeys
check_if_system_has_rebooted=/root/.reboot_needed

usage ()
{
	/bin/echo "Usage : $0 <action>"
	/bin/echo "	List of actions:"
	/bin/echo "		check_install :	Check if needed softwares are installed, if not install them"
	/bin/echo "		generate_keys :	Generate keys (private, public and the certificates)"
	/bin/echo "		sign_file :	Sign the file passed as a parameter using the designated keys"
	/bin/echo "		export_keys :	export newly generated keys to a safe location"
}

check_install ()
{
	program_array=(
	"app-crypt/efitools"
	"app-crypt/sbsigntools"
	"dev-libs/openssl"
	)

	# Check if program is installed, if not install it
	for program in ${program_array[@]}; do
		if [[ $(emerge -p $program | grep -i "ebuild  N") ]]
		then
			/bin/echo "[*] $program is not installed, going for installation..." && \
			emerge -q $program && \
			/bin/echo -e "${GREEN}[*] Done ! ${NC}"
		else
			/bin/echo -e "${GREEN}[*] $program is already installed !${NC}"
		fi
	done
}

generate_keys ()
{
	/bin/echo "[*] Generate keys process..."
	# check if repository /etc/efikeys exists
	if [[ ! -f $check_if_system_has_rebooted ]]
	then
		/bin/echo "[*] Entering phase 1 !"
		/bin/echo "[*] Create directory and backup old PK, KEK, db and dbx variables"
		if [[ ! -d $efikeys_folder ]]
		then
			/bin/mkdir $efikeys_folder
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

		/bin/echo "[*] Preparing Keystore update Files from Keys"
		# First, we make a signature list (which requires a unique ID, the value of which is essentially unimportant), and then we use our own (private) platform key to sign it
		# cert-to-efi-sig-list - tool for converting openssl certificates to EFI signature lists
		# sign-efi-sig-list - signing tool for secure variables as EFI Signature Lists
		# 'signed signature list' (aka '.auth')
		# efi-updatevar will only accept it in this format.
		/usr/bin/cert-to-efi-sig-list -g "$(uuidgen)" PK.crt PK.esl && \
		/usr/bin/cert-to-efi-sig-list -g "$(uuidgen)" KEK.crt KEK.esl && \
		/usr/bin/cert-to-efi-sig-list -g "$(uuidgen)" db.crt db.esl && \
		/usr/bin/sign-efi-sig-list -k PK.key -c PK.crt PK PK.esl PK.auth && \
		/usr/bin/sign-efi-sig-list -a -k PK.key -c PK.crt KEK KEK.esl KEK.auth && \
		/usr/bin/sign-efi-sig-list -a -k KEK.key -c KEK.crt db db.esl db.auth && \
		/usr/bin/sign-efi-sig-list -k KEK.key -c KEK.crt dbx old_dbx.esl old_dbx.auth && \
		/bin/echo -e "${GREEN}[*] Done !${NC}"

		/bin/echo "[*] Converting x509 certificat to DER format"
		/usr/bin/openssl x509 -outform DER -in PK.crt -out PK.cer && \
		/usr/bin/openssl x509 -outform DER -in KEK.crt -out KEK.cer && \
		/usr/bin/openssl x509 -outform DER -in db.crt -out db.cer && \
		/bin/echo -e "${GREEN}[*] Done !${NC}"

		/bin/echo "[*] Merging EFI keys and signing them"
		cat old_KEK.esl KEK.esl > compound_KEK.esl && \
		cat old_db.esl db.esl > compound_db.esl && \
		/usr/bin/sign-efi-sig-list -k PK.key -c PK.crt KEK compound_KEK.esl compound_KEK.auth && \
		/usr/bin/sign-efi-sig-list -k KEK.key -c KEK.crt db compound_db.esl compound_db.auth && \
		/bin/echo -e "${GREEN}[*] Done !${NC}"

		# Time to clear the UEFI secure boot variables, thereby entering setup mode and restart the machine
		/bin/echo "[*] You will need to reboot your system to modify UEFI parameters related to secure boot"
		/bin/echo "You will need to:"
		/bin/echo "	1. Clean EFI registers related to Secure Boot keys"
		/bin/echo "	2. Turn SecureBoot in Setup Mode"
		/bin/echo "	3. Turn SecureBoot OFF"
		/bin/echo " 	4. Save and exit"
		/bin/echo "[?] are you ready to restart (Y/N) ?"
		read user_choice
		if [[ $user_choice == "Y" ]]
		then
			/bin/echo "[*] Your system will restart in 5 seconds" && \
			/usr/bin/touch $check_if_system_has_rebooted && \
			/usr/bin/sleep 5 && \
			/sbin/reboot
		else
			/bin/echo -e "${RED}[*] the user is not ready to restart ${NC}" && \
			/usr/bin/touch $check_if_system_has_rebooted && \
			exit 0
		fi
	elif [[ -f $check_if_system_has_rebooted ]]
	then
		/bin/echo "[*] Entering phase 2 !"
		/bin/echo "[*] Update EFI variables for secureboot"
		cd $efikeys_folder && \
		# The -e option specifies that an EFI signature list file is to be loaded (and the -f option precedes the filename itself).
		# Because we are in setup mode, no private key is required for these operations (which it would be, if we were in user mode).
		/usr/bin/efi-updatevar -e -f old_dbx.esl dbx && \
		/usr/bin/efi-updatevar -e -f compound_db.esl db && \
		/usr/bin/efi-updatevar -e -f compound_KEK.esl KEK && \
		/usr/bin/efi-updatevar -f PK.auth PK && \
		/usr/bin/efi-readvar
		/bin/echo "[?] Please check the content of the different EFI variables, is everyting correct ? (Y/N)"
		read user_choice
		if [[ ! $user_choice == "Y" ]]
		then
			/bin/echo -e "${RED}[*] The content of EFI variables are not right, exiting... ${NC}"
			exit 1
		fi

		/bin/echo "[*] Backup new efi variables"
		/usr/bin/efi-readvar -v PK -o new_pk.esl && \
		/usr/bin/efi-readvar -v KEK -o new_kek.esl && \
		/usr/bin/efi-readvar -v db -o new_db.esl && \
		/usr/bin/efi-readvar -v dbx -o new_dbx.esl && \
		/bin/echo -e "${GREEN}[*] Done !${NC}"

		if [[ ! $(lsblk | /bin/grep -i boot) ]]
		then
			/bin/echo "[*] The boot partiton is not mounted !, mounting it..." && \
			/bin/mount $(/sbin/blkid | /bin/grep -i boot | /usr/bin/cut -d ":" -f1) /boot && \
			/bin/echo -e "${GREEN}[*] Done !${NC}"
		fi
		/bin/echo -e "${RED}[*] Don't forget to export the generated keys inside the folder: $efikeys_folder to a safe location !!! ${NC}"
		/bin/echo "[*] You will need to reboot your system and modify UEFI parameters related to secure boot"
		/bin/echo "	1. Turn SecureBoot in User Mode"
		/bin/echo "	2. Turn SecureBoot ON"
		/bin/echo "[?] Are you ready to restart (Y/N) ?"
		read user_choice
		if [[ $user_choice == "Y" ]]
		then
				/bin/echo "[*] Your system will restart in 5 seconds" && \
				/bin/rm $check_if_system_has_rebooted && \
				/usr/bin/sleep 5 && \
				/sbin/reboot
		else
				/bin/echo -e "${RED}[*] The user is not ready to restart ${NC}" && \
				/bin/rm $check_if_system_has_rebooted && \
				exit 0
		fi
	else
		/bin/echo -e "${RED}[*] Something wrong happened... ${NC}"
		exit 1
	fi
}

sign_file ()
{
	/bin/echo "[*] Signing file process..."
	/bin/echo "[?] Please give the file location and name (example: /boot/EFI/gentoo/bzImage) ?"
	read file_to_sign
	/bin/echo "[?] Please give the folder where are stored the db private and public keys (example: /media/veracrypt3) ?"
	read keys_path
	/bin/cp $file_to_sign $file_to_sign-unsigned && \
	/usr/bin/sbsign --key $keys_path/db.key --cert $keys_path/db.crt $file_to_sign-unsigned --output $file_to_sign && \
	/bin/rm $file_to_sign-unsigned && \
	/bin/echo -e "${GREEN}[*] Done !${NC}"
}

export_keys ()
{
	/bin/echo "[*] Export keys process..."
	/bin/echo "[?] Please give the path to an ENCRYPT folder where to store the keys (example: /media/veracrypt3) ?"
	read encrypted_folder
	/bin/cp -r $efikeys_folder $encrypted_folder && \
	/bin/echo -e "${GREEN}[*] Done !${NC}" 
	echo "[?] Are ready to remove the folder: $efikeys_folder (Y/N) ?"
	read user_choice
	if [[ $user_choice == "Y" ]]
	then
		/bin/echo -e "[*] Removing folder: $efikeys_folder" 
		/bin/rm -rf $efikeys_folder && \
		/bin/echo -e "${GREEN}[*] Done !${NC}" 
	else
		echo "[*] You will have to remove this folder later !" && \
		exit 0
	fi
}


if [[ "$EUID" -ne 0 ]];
then
  /bin/echo -e "${RED}[*] Please run this script as root ${NC}" && \
  exit 1
fi


echo "[*] Secure Boot configuration script !"
echo "[*] Caution this script makes the assumption you are running a EFI stub kernel !"
echo "[*] If you are using a bootloader like GRUB, this script won't work !"
echo "[?] Are you sure you want to continue (Y/N) ?"
read user_choice
if [[ ! $user_choice == "Y" ]]
then
	echo -e "${RED}[*] Exiting... ${NC}"
	exit 1
fi

user_choice=$1
if [[ $user_choice == "check_install" ]]
then
	check_install
elif [[ $user_choice == "generate_keys" ]]
then
	generate_keys
elif [[ $user_choice == "sign_file" ]]
then
	sign_file
elif [[ $user_choice == "export_keys" ]]
then
	export_keys
else
	usage
fi
