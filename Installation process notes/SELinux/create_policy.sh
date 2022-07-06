#!/bin/bash

policy_file=$1

usage ()
{
  /bin/echo "ERROR! Usage:"
  /bin/echo "$0 <policy_file>"
  /bin/echo "Example: $0 <policy_file>"
  exit 1
}

if [ -z $1 ];
then
  usage
fi

ausearch -m AVC | audit2allow -m $policy_file -o $policy_file.te

if [ $(semodule -l | grep $policy_file) ]
then
  echo "[*] $policy_file FOUND !!!, removing old one !"
  semodule -r $policy_file
  echo "[*] Done !"
fi
echo "[*] Compiling and installing new policy"
make -f /usr/share/selinux/strict/include/Makefile $policy_file.pp && semodule -i $policy_file.pp
echo "[*] Done !"

