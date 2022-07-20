#!/bin/bash

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No colors

bwrap_github_path=https://raw.githubusercontent.com/RomainLanglois/Gentoo/main/Bash_Scripts/bwrap_profiles/
bwrap_profiles_array=(
	"sandbox_7zip.sh"
	"sandbox_evince.sh"
	"sandbox_firefox.sh"
)

install_and_configure_bwrap ()
{
	/bin/echo "[*] Installing bubblewrap"
	/usr/bin/emerge --ask sys-apps/bubblewrap && \
	/bin/echo -e "${GREEN}[*] Done ! ${NC}"
	/bin/echo "[*] Downloading and configuring bubblewrap profiles"
	for bwrap_profiles in ${bwrap_profiles_array[@]}; do
	  /usr/bin/wget --quiet $bwrap_github_path$bwrap_profiles -O /bin/$bwrap_profiles && \
	  /bin/chmod +x /bin/$bwrap_profiles && \
	  /bin/echo -e "${GREEN}[*] Profile: $bwrap_profiles correctly downloaded and configured ! ${NC}"
	done
}

install_and_configure_firewall ()
{
	/bin/echo "[*] Configuring iptables"
	/sbin/iptables -F && \
	/sbin/iptables -X && \
	/sbin/iptables -Z && \
	/sbin/iptables -P FORWARD DROP && \
	/sbin/iptables -P INPUT DROP && \
	/sbin/iptables -P OUTPUT ACCEPT && \
	/sbin/iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT && \
	/sbin/iptables -A INPUT -i lo -j ACCEPT && \
	/sbin/iptables -A INPUT -m conntrack --ctstate INVALID -j DROP && \
	/sbin/iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT && \
	/sbin/iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable && \
	/sbin/rc-service iptables save && \
	/sbin/rc-service iptables start && \
	/sbin/rc-update add iptables default && \
	/bin/echo -e "${GREEN}[*] Done ! ${NC}"
}

install_and_configure_usb-guard ()
{
	/bin/echo "[*] Installing and configuring usbguard in version 1.1.1-r3 !"
	/bin/echo '=sys-apps/usbguard-1.1.1-r3 ~amd64' > /etc/portage/package.accept_keywords/usbguard && \
	/usr/bin/emerge --ask sys-apps/usbguard && \
	/usr/bin/usbguard generate-policy > /etc/usbguard/rules.conf && \
	/sbin/rc-update add usbguard default && \
	/sbin/rc-service usbguard start && \
	/bin/echo -e "${GREEN}[*] Done ! ${NC}"
}

if [[ "$EUID" -ne 0 ]];
then
  /bin/echo -e "${RED}[*] Please run this script as root ${NC}"
  exit 1
fi

install_and_configure_bwrap && \
install_and_configure_firewall && \
install_and_configure_usb-guard

