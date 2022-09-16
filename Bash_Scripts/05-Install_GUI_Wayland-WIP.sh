#!/bin/bash

make_file=/etc/portage/make.conf

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
	# For Wayland support (A tester !)
	/bin/grep USE /etc/portage/make.conf | /bin/sed -i "s#\"\$# X alsa wayland xwayland\"#g" /etc/portage/make.conf
	#/usr/bin/euse -E X, alsa, wayland, xwayland
	/bin/echo "INPUT_DEVICES=\"libinput synaptics\"" >> $make_file
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
echo "dev-qt/qtgui egl" >> /etc/portage/package.use && \
/usr/bin/emerge --ask dev-libs/wayland dev-qt/qtwayland x11-base/xwayland && \
/usr/bin/emerge --ask --changed-use --deep @world && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Installing Sway"
/usr/bin/emerge --ask gui-wm/sway gui-apps/foot && \
/usr/sbin/adduser -a -G video $(/bin/grep "1000" /etc/passwd | /bin/cut -d ":" -f1) && \
/sbin/rc-update add seatd && \
/sbin/rc-service seatd start && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Installing other GUI components"
/usr/bin/emerge -q x11-misc/arandr gui-apps/wl-clipboard app-text/evince gnome-extra/nm-applet && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

# A tester !
/bin/echo "###########################################"
/bin/echo "[*] Installing web browsers (Firefox and Brave)" && \
/bin/echo "app-text/ghostscript-gpl cups" >> /etc/portage/package.use && \
/bin/echo "app-text/xmlto text" >> /etc/portage/package.use && \
/usr/bin/eselect repository enable brave-overlay && \
/usr/sbin/emaint sync -r brave-overlay && \
/usr/bin/emerge -q www-client/firefox-bin www-client/brave-bin && \
/bin/echo "[*] Done !" && \
/bin/echo "###########################################"
# A tester !

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
