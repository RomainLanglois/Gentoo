#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No colors
policy_file=$(basename $1 .te)

usage ()
{
  /bin/echo -e "${RED}ERROR! Usage:"
  /bin/echo -e "  $0 <name_of_SELinux_policy>"
  /bin/echo -e "  Example: $0 allow_xorg_user-u.te"
  exit 1
}

compile_and_install_SELinux_policy ()
{
	/bin/echo -e "${GREEN}[*] Compiling and installing new policy ${NC}"
	/usr/bin/make -f /usr/share/selinux/strict/include/Makefile $1.pp && /usr/sbin/semodule -i $1.pp && /bin/echo -e "${GREEN} [*] Done ! ${NC}"
}

if [ -z $1 ];
then
  usage
fi

if [[ $(/usr/sbin/semodule -l | /bin/grep $policy_file) ]];
then
  /bin/echo -e "${RED} [*]$policy_file FOUND !!!, removing old one ! ${NC}"
  /usr/sbin/semodule -r $policy_file && /bin/echo -e "${GREEN}[*] Done ! ${NC}"
fi

/bin/echo -e "Do you want to create a policy based on the audit.log file(1) OR use your own custom policy file(2) ?"
read user_choice
if [[ $user_choice == "1" ]];
then
	/sbin/ausearch -m AVC | /usr/bin/audit2allow -m $policy_file -o $policy_file.te
	compile_and_install_SELinux_policy $policy_file
elif [[ $user_choice == "2" ]];
then
	compile_and_install_SELinux_policy $policy_file
else
	/bin/echo -e "${RED}Please select 1 OR 2 ${NC}"
	exit 1
fi

