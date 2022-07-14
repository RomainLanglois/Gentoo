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
	/bin/echo "[*] No modifications added the make.conf file"
fi
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Remerging the packages which needs those USE flags"
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

# TODO 
# Rajouter Brave
/bin/echo "###########################################"
/bin/echo "[*] Installing other critical components for the GUI to work"
/usr/bin/emerge -q x11-misc/xautolock x11-misc/dmenu x11-terms/terminator www-client/firefox-bin media-gfx/feh && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Please enter the username who will receive the GUI configuration: "
read username
user_folder=/home/$username
/bin/echo "###########################################"
/bin/echo "[*] Configuring .xinitrc file"
/bin/echo "exec i3" >> $user_folder/.xinitrc && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Configuring i3"
i3_config_folder=$user_folder/.config/i3
git_tmp_folder=/tmp/I3-configuration
/bin/mkdir $user_folder/.config && \
/bin/mkdir $user_folder/.config/i3 && \
cd /tmp && \
/usr/bin/git clone https://github.com/RomainLanglois/I3-configuration.git && \
/bin/cp $git_tmp_folder/config $i3_config_folder && \
/bin/cp -r $git_tmp_folder/scripts $i3_config_folder && \
/bin/cp -r $git_tmp_folder/wallpaper $i3_config_folder && \
/bin/rm -rf $git_tmp_folder && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Install and configure alsa (Sound)"
/usr/bin/emerge --ask media-sound/alsa-utils && \
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
	/usr/sbin/reboot
else
	/bin/echo "[*] Exiting script"
fi

: '

'


