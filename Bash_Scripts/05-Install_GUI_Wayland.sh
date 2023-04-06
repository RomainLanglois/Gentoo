#!/bin/bash

set -e

make_file=/etc/portage/make.conf
package_use_file=/etc/portage/package.use

if [[ "$EUID" -ne 0 ]];
  then
  /bin/echo "Please run this script as root"
  exit 1
fi

/bin/echo "###########################################"
/bin/echo "[*] Setting-up make.conf file"
/bin/echo "[*] Do you need to update your make.conf file to install a GUI (Y/N) ?"
read user_choice
if [[ $user_choice == "Y" ]];
then
	/usr/bin/euse -E X && \
	/usr/bin/euse -E alsa && \
	/usr/bin/euse -E wayland && \
	/usr/bin/euse -E xwayland && \
	/usr/bin/euse -E elogind && \
	/usr/bin/euse -E alsa && \
	/bin/echo "INPUT_DEVICES=\"libinput synaptics\"" >> $make_file && \
	/bin/echo "VIDEO_CARDS=\"intel\"" >> $make_file
else
	/bin/echo "[*] No modifications added to make.conf file"
fi
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Updating @world variable"
/usr/bin/emerge --ask --changed-use --deep @world && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Installing Wayland"
/bin/echo "dev-qt/qtgui egl" >> $package_use_file && \
/usr/bin/emerge -q dev-libs/wayland dev-qt/qtwayland x11-base/xwayland && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Installing Sway"
/usr/bin/emerge -q gui-wm/sway gui-apps/foot sys-auth/elogind && \
/sbin/rc-update add elogind boot && \
/sbin/rc-service elogind start && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Installing other GUI components"
/bin/echo "app-text/poppler cairo " >> $package_use_file && \
/bin/echo "app-crypt/gcr gtk" >> $package_use_file && \
/bin/echo "app-admin/keepassxc yubikey" >> $package_use_file && \
/bin/echo "media-libs/harfbuzz icu" >> $package_use_file && \
/bin/echo "dev-libs/xmlsec nss" >> $package_use_file && \
/bin/echo "app-crypt/veracrypt truecrypt-3.0" >> /etc/portage/package.license && \
/usr/bin/emerge -q gui-apps/kanshi gui-apps/wl-clipboard app-text/evince gnome-extra/nm-applet app-admin/keepassxc app-crypt/veracrypt x11-misc/grsync app-office/libreoffice-bin && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Installing web browsers (Firefox and Brave)" && \
/bin/echo "app-text/ghostscript-gpl cups" >> $package_use_file && \
/bin/echo "app-text/xmlto text" >> $package_use_file && \
/bin/echo "media-plugins/alsa-plugins pulseaudio" >> $package_use_file && \
/usr/bin/eselect repository enable brave-overlay && \
/usr/sbin/emaint sync -r brave-overlay && \
/usr/bin/emerge -q www-client/firefox-bin www-client/brave-bin && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Install and configure alsa (Sound)"
/usr/bin/emerge -q media-sound/alsa-utils && \
/sbin/rc-service alsasound start && \
/sbin/rc-update add alsasound boot && \
/usr/bin/amixer set Master toggle && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] You will need to restart your system, are you ready (Y/N) ?"
read user_choice
if [[ $user_choice == "Y" ]];
then
	/bin/echo "[*] Rebooting in 5 seconds..."
	/usr/bin/sleep 5
	/sbin/reboot
else
	/bin/echo "[*] Exiting script"
fi
