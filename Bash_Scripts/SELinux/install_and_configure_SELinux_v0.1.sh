#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No colors
selinux_config_file=/etc/selinux/config
make_file=/etc/portage/make.conf

install_and_configure_selinux ()
{
	/bin/echo -e "${GREEN} Installing tools for SELinux: ${NC}"
        /bin/sed -i "s#SELINUX=enforcing#SELINUX=permissive#g" $selinux_config_file && \
        FEATURES="-selinux -sesandbox" /usr/bin/emerge -1 selinux-base && \
	FEATURES="-selinux -sesandbox" /usr/bin/emerge -1 selinux-base-policy && \
	/usr/bin/emerge -uDN @world && \
	/bin/echo -e "${GREEN} Done ! ${NC}"
}

label_system ()
{
	/bin/echo -e "${GREEN} Labelling Filesystem ${NC}"
	# TODO : un check sur le dossier /mnt/gentoo -> Est-ce nécessaire ?
	/bin/mkdir /mnt/gentoo && \
	/bin/mount -o bind / /mnt/gentoo && \
	/usr/sbin/setfiles -r /mnt/gentoo /etc/selinux/strict/contexts/files/file_contexts /mnt/gentoo/{dev,home,proc,run,sys,tmp} && \
	umount /mnt/gentoo && \
	/usr/sbin/rlpkg -a -r && \
	/bin/echo -e "${GREEN} Done ! ${NC}"
}

define_selinux_users ()
{
	/bin/echo -e "Configuring SELinux users"
	/bin/echo -e "Configuring root account"
	/usr/sbin/semanage login -a -s root root && /sbin/restorecon -R -F /root
	/bin/echo -e "Configuring local unpriviledge account"
	/bin/echo -e "Enter the linux username:"
	read linux_username
	/bin/echo -e "Enter the corresponding SELinux account:"
	read selinux_username
	/usr/sbin/semanage login -a -s $selinux_username $linux_username && /sbin/restorecon -R -F /home/$linux_username && /bin/echo -e "${GREEN} Done ! ${NC}"
}

/bin/echo -e "---------------------------------------------------------"
/bin/echo -e "CAUTION !!!!"
/bin/echo -e "This script is going to configure SELinux for this system"
/bin/echo -e "1) Be sure to have a working system before continuing"
/bin/echo -e "2) Make sure your kernel support SELinux !!!!"
/bin/echo -e "---------------------------------------------------------"

/bin/echo -e "[*] Are you sure you want to continue ? (Y/N)"
read user_choice
if [[ $user_choice != "Y" ]];
then
	/bin/echo -e "Exiting..."
	exit 1
fi

/bin/echo -e "[*] Showing current profile:"
/usr/bin/eselect profile list
/bin/echo -e "[*] Do you need to move to the hardened SELinux profile ? (Y/N)"
read user_choice
if [[ $user_choice == "Y" ]];
then
	/bin/echo -e "Select the profile number:"
	read profile_number
	/usr/bin/eselect profile set $profile_number
fi

if [[ ! $(/bin/grep -i "POLICY_TYPES" $make_file) ]];
then
	/bin/echo -e "[*] No POLICY_TYPES found inside make file, adding one..."
	/bin/echo -e "POLICY_TYPES=\"strict targeted\"" >> $make_file && \
	/bin/echo -e "${GREEN}Done !${NC}"
fi

/bin/echo -e "[*] Installing SELinux base package"
FEATURES="-selinux" /usr/bin/emerge -1 selinux-base && /bin/echo -e "${GREEN}Done !${NC}"
/bin/echo -e "Do you want to configure SELinux in Targeted mode (1) or Strict mode (2) ?"
read user_choice
if  [[ $user_choice == 1 ]];
then
	/bin/echo -e "[*] Setting WORLD variable:"
	# PB avec cette ligne de commande
	/usr/bin/euse -E peer_perms && /usr/bin/euse -E ubac && /usr/bin/euse -E unconfined
	/bin/sed -i "s#SELINUXTYPE=strict#SELINUXTYPE=targeted#g" $selinux_config_file
	install_and_configure_selinux && label_system
elif [[ $user_choice == 2 ]];
then
	/bin/echo -e "[*] Setting WORLD variable:"
	# PB avec cette ligne de commande
	/usr/bin/euse -E peer_perms && /usr/bin/euse -E ubac
	install_and_configure_selinux && label_system && define_selinux_users
else
	/bin/echo -e "${RED}No mode selected or invalid input, exiting...${NC}"
fi
