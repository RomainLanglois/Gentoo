#!/bin/bash

make_file=/etc/portage/make.conf
i3_config_folder=~/.config/i3
git_tmp_folder=/tmp/i3-configuration

/bin/echo "###########################################"
/bin/echo "[*] Setting-up make.conf file"
/bin/echo "[*] Do you need to update your make.conf file (Y/N) ?"
read user_choice
if [[ $user_choice == "Y" ]];
then
	/usr/bin/euse -E X
	/usr/bin/euse -E alsa
	/bin/echo "INPUT_DEVICES="libinput synaptics"" >> $make_file
	/bin/echo "VIDEO_CARDS="intel"" >> $make_file
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

/bin/echo "###########################################"
/bin/echo "[*] Configuring .xinitrc file"
/bin/echo "exec i3" >> ~/.xinitrc && \
/bin/echo "[*] Done !"
/bin/echo "###########################################"

/bin/echo "###########################################"
/bin/echo "[*] Configuring i3"
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
