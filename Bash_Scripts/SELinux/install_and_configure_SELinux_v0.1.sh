#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No colors
selinux_config_file=/etc/selinux/config
make_file=/etc/portage/make.conf
package_use_file=/etc/portage/package.use
check_if_system_has_rebooted=/root/.reboot_needed

install_and_configure_selinux ()
{
	/bin/echo -e "${GREEN}[*] Installing tools for SELinux and updating WORLD variable: ${NC}"
	FEATURES="-selinux -sesandbox" /usr/bin/emerge -1 selinux-base && \
	FEATURES="-selinux -sesandbox" /usr/bin/emerge -1 selinux-base-policy && \
	/usr/bin/emerge -uDN @world && \
	/bin/echo -e "${GREEN}[*] Done ! ${NC}"
}

label_system ()
{
	/bin/echo -e "${GREEN}[*] Labelling Filesystem ${NC}"
	if [[ ! -d /mnt/gentoo ]];
	then
		/bin/mkdir /mnt/gentoo
	fi
	/bin/mount -o bind / /mnt/gentoo && \
	/usr/sbin/setfiles -r /mnt/gentoo /etc/selinux/strict/contexts/files/file_contexts /mnt/gentoo/{dev,home,proc,run,sys,tmp} && \
	/bin/umount /mnt/gentoo && \
	/usr/sbin/rlpkg -a -r && \
	/bin/rmdir /mnt/gentoo && \
	/bin/echo -e "${GREEN}[*] Done ! ${NC}"
}

define_selinux_users ()
{
	policy_type=$1
	
	/bin/echo -e "${GREEN}[*] Configuring SELinux users ${NC}"
	if [[ $policy_type == "targeted" ]];
	then
		/bin/echo -e "${GREEN}[*] Targeted SELinux policy chosen ! ${NC}"
		/bin/echo -e "[*] Configuring root account"
		/usr/sbin/semanage login -a -s unconfined_u root && /sbin/restorecon -R -F /root
		/bin/echo -e "${GREEN}[*] Configuring local unpriviledge account ${NC}"
		/bin/echo -e "[?] Enter the linux username:"
		read linux_username
		/usr/sbin/semanage login -a -s unconfined_u $linux_username && /sbin/restorecon -R -F /home/$linux_username && /bin/echo -e "${GREEN}Done ! ${NC}"	
	elif [[ $policy_type == "strict" ]];
	then
		/bin/echo -e "${GREEN}[*] Strict SELinux policy chosen !"
		/bin/echo -e "[*] Configuring root account ${NC}"
		/usr/sbin/semanage login -a -s root root && /sbin/restorecon -R -F /root
		/bin/echo -e "${GREEN}[*] Configuring local unpriviledge account ${NC}"
		/bin/echo -e "[?] Enter the linux username:"
		read linux_username
		/bin/echo -e "[?] Enter the corresponding SELinux account:"
		read selinux_username
		/usr/sbin/semanage login -a -s $selinux_username $linux_username && /sbin/restorecon -R -F /home/$linux_username && /bin/echo -e "${GREEN}Done ! ${NC}"
	else
		echo "${RED}[*]Wrong parameter passed to function $0 ${NC}"
		exit 1
	fi
	
	/bin/echo -e "${GREEN}[*] Setting selinux=1 kernel parameter ${NC}"
	/bin/sed -i "s#selinux=0#selinux=1#g" /etc/default/grub
	if [[ ! $(lsblk | grep -i boot) ]];
	then
		/bin/mount $(blkid | grep -i boot | cut -d ":" -f1)
	fi
	/usr/sbin/grub-mkconfig -o /boot/grub/grub.cfg
	/bin/echo -e "${GREEN}[*] Done !${NC}"
	/bin/echo "[*] You need to restart your system to apply kernel parameter selinux=1"
	/bin/echo "[?] Are you ready to restart (Y/N) ?"
	read user_choice
	if [[ $user_choice == "Y" ]];
	then
		/bin/echo "[*] Your system will reboot in five seconds..."
		/bin/sleep 5
		/sbin/reboot
	else
		/bin/echo "[*] The user is not ready to restart existing !"
		exit 0
	fi
}

if [[ "$EUID" -ne 0 ]];
  then 
  /bin/echo "${RED}[*] Please run this script as root ${NC}"
  exit 1
fi

/bin/echo -e "---------------------------------------------------------"
/bin/echo -e "CAUTION !!!!"
/bin/echo -e "This script is going to configure SELinux for this system"
/bin/echo -e "1) Be sure to have a working system before continuing"
/bin/echo -e "2) Make sure your kernel support SELinux !!!!"
/bin/echo -e "---------------------------------------------------------"

/bin/echo -e "[?] Are you sure you want to continue ? (Y/N)"
read user_choice
if [[ $user_choice != "Y" ]];
then
	/bin/echo -e "Exiting..."
	exit 1
fi

if [[ ! -f $check_if_system_has_rebooted ]] ;
then
	/bin/echo -e "${GREEN}[*] Entering SELinux configuration PHASE 1 ! ${NC}"
	/bin/echo -e "[*] Showing current profile:"
	/usr/bin/eselect profile list
	/bin/echo -e "[?] Do you need to move to the hardened SELinux profile ? (Y/N)"
	read user_choice
	if [[ $user_choice == "Y" ]];
	then
		/bin/echo -e "[?] Select the profile number:"
		read profile_number
		/usr/bin/eselect profile set $profile_number
	fi

	if [[ ! $(/bin/grep -i "POLICY_TYPES" $make_file) ]];
	then
		/bin/echo -e "[*] No POLICY_TYPES found inside make file, adding one..."
		/bin/echo -e 'POLICY_TYPES="strict targeted"' >> $make_file && \
		/bin/echo -e "${GREEN}[*] Done !${NC}"
	fi

	/bin/echo -e "[*] Installing SELinux base package"
	/bin/echo "dev-python/PyQt5 widgets gui" >> $package_use_file && \
	/bin/echo "dev-libs/libpcre2 static-libs" >> $package_use_file && \
	/bin/echo "sys-libs/libselinux python" >> $package_use_file && \
	/bin/echo "sys-process/audit python" >> $package_use_file && \
	FEATURES="-selinux" /usr/bin/emerge -1 selinux-base && \
	/bin/echo -e "${GREEN}[*] Done !${NC}"
	/bin/echo "${GREEN}[*] You need to restart your system before continuing ${NC}"
	/bin/echo "${GREEN}[*] Preparing the environment... ${NC}"
	/usr/bin/touch $check_if_system_has_rebooted && \
	/bin/sed -i "s#dolvm crypt_root=UUID=\"$(blkid | grep -i luks | cut -d '"' -f2)\" keymap=fr#dolvm crypt_root=UUID=\"$(blkid | grep -i luks | cut -d '"' -f2)\" keymap=fr selinux=0#g" /etc/default/grub
	if [[ ! $(lsblk | grep -i boot) ]];
	then
		/bin/mount $(blkid | grep -i boot | cut -d ":" -f1)
	fi
	/usr/sbin/grub-mkconfig -o /boot/grub/grub.cfg
	/bin/echo "[*] You will need to re-execute this script to finish the installation process"
	/bin/echo "[?] Are you ready to restart (Y/N) ?"
	read user_choice
	if [[ $user_choice == "Y" ]];
	then
		/bin/echo "[*] Your system will reboot in five seconds..."
		/bin/sleep 5
		/sbin/reboot
	else
		/bin/echo "[*] The user is not ready to restart existing !"
		exit 0
	fi
	
elif [[ -f $check_if_system_has_rebooted ]] ;
then
	/bin/echo -e "${GREEN}[*] Entering SELinux configuration PHASE 2 ! ${NC}"
	/bin/echo -e "[*] Do you want to configure SELinux in Targeted mode (1) or Strict mode (2) ?"
	read user_choice
	if  [[ $user_choice == 1 ]];
	then
		/bin/echo -e "[*] Setting USE variable:"
		/usr/bin/euse -E ubac && \
		/usr/bin/euse -E unconfined && \
		/bin/sed -i "s#SELINUXTYPE=strict#SELINUXTYPE=targeted#g" $selinux_config_file && \
		install_and_configure_selinux && label_system && define_selinux_users targeted
		/bin/rm $check_if_system_has_rebooted
	elif [[ $user_choice == 2 ]];
	then
		/bin/echo -e "[*] Setting USE variable:"
		/usr/bin/euse -E ubac && \ 
		install_and_configure_selinux && label_system && define_selinux_users strict
		/bin/rm $check_if_system_has_rebooted
	else
		/bin/echo -e "${RED}No mode selected or invalid input, exiting..."
		/bin/echo -e "Choice : Targeted -> 1"
		/bin/echo -e "Choice : Strict -> 2 ${NC}"
		exit 1
	fi
else
	/bin/echo -e "${RED} Something wrong happend. Exiting script... ${NC}"
	exit 1
fi
