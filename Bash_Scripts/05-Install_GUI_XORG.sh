#!/bin/bash

make_file=/etc/portage/make.conf

if [[ "$EUID" -ne 0 ]];
  then 
  /bin/echo "Please run this script as root"
  exit 1
fi

/bin/echo "###########################################"
/bin/echo "[*] Setting-up make.conf file"
/bin/echo "[*] Do you need to update your make.conf file to support XORG (Y/N) ?"
read user_choice
if [[ $user_choice == "Y" ]];
then
	/usr/bin/euse -E X
	/usr/bin/euse -E alsa
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
/bin/echo "[*] Installing Xorg server and make it rootless"
/bin/echo "sys-auth/pambase elogind" >> /etc/portage/package.use && \
/usr/bin/emerge -q x11-base/xorg-server x11-base/xorg-drivers && \
env-update && \
source /etc/profile && \
/sbin/rc-update add elogind boot && \
/sbin/rc-service elogind start && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Installing I3"
/usr/bin/emerge -q x11-wm/i3-gaps x11-misc/i3blocks x11-misc/i3lock x11-misc/i3status && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Installing other GUI components"
/bin/echo "media-plugins/alsa-plugins pulseaudio" >> /etc/portage/package.use && \
/bin/echo "app-text/poppler cairo" >> /etc/portage/package.use && \
/bin/echo "app-crypt/gcr gtk" >> /etc/portage/package.use && \
/usr/bin/emerge -q x11-misc/xautolock x11-misc/dmenu x11-misc/arandr x11-terms/terminator www-client/firefox-bin media-gfx/feh app-text/evince gnome-extra/nm-applet && \
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
/bin/echo "[*] Setting keyboard layout to french for XORG"
/bin/mkdir /etc/X11/xorg.conf.d && \
/bin/echo 'Section "InputClass"
    Identifier "keyboard"
    Driver "evdev"
    Option "XkbLayout" "fr"
    Option "XkbVariant" "oss"
    Option "XkbOptions" "compose:menu"
    MatchIsKeyboard "on"
EndSection' > /etc/X11/xorg.conf.d/10-keyboard.conf && \
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
