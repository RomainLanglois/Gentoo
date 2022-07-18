#!/bin/bash

# TODO
# Bwrap
# Iptables
# Usb Guard

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No colors

if [[ "$EUID" -ne 0 ]];
  then
  /bin/echo -e "${RED}[*] Please run this script as root ${NC}"
  exit 1
fi

install_and_configure_bwrap
{
	echo "[*] Installing bwrap"
	emerge --ask sys-apps/bubblewrap && \
	echo "${GREEN}[*] Done ! ${NC}"
	echo "[*] Downloading and configuring bubblewrap profiles"
	cd /bin && \
	wget https://raw.githubusercontent.com/RomainLanglois/Gentoo/main/Bash_Scripts/bwrap_profiles/sandbox_7zip.sh && \
	wget https://raw.githubusercontent.com/RomainLanglois/Gentoo/main/Bash_Scripts/bwrap_profiles/sandbox_evince.sh && \
	wget https://raw.githubusercontent.com/RomainLanglois/Gentoo/main/Bash_Scripts/bwrap_profiles/sandbox_firefox.sh && \
	chmod +x sandbox_7zip.sh sandbox_evince.sh sandbox_firefox.sh && \
	echo "${GREEN}[*] Done ! ${NC}"
}

install_and_configure_iptables
{
	echo "install_and_configure_iptables"
}

install_and_configure_usb-guard
{
	echo "[*] Installing and configuring usbguard"
	emerge --ask sys-apps/usbguard && \
	usbguard generate-policy > /etc/usbguard/rules.conf && \
	# usbguard.service
	rc-service add usbguard default && \
	echo "${GREEN}[*] Done ! ${NC}"
}

install_and_configure_bwrap && \
install_and_configure_iptables && \
install_and_configure_usb-guard
