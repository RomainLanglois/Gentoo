#!/bin/bash
make_file=/etc/portage/make.conf

echo "###########################################"
echo "Setting-up make.conf file"
euse -E X 
euse -E alsa
echo "INPUT_DEVICES="libinput synaptics"" >> $make_file
echo "VIDEO_CARDS="intel"" >> $make_file
echo "Done !"
echo "###########################################"

echo "###########################################"
echo "Remerging the packages which needs those USE flags"
emerge --ask --changed-use --deep @world
echo "Done !"
echo "###########################################"

echo "###########################################"
echo "Installing Xorg server and make it rootless"
echo "sys-auth/pambase elogind" >> /etc/portage/package.use 
emerge -q x11-base/xorg-server x11-base/xorg-drivers
env-update
source /etc/profile 
rc-update add elogind boot
/etc/init.d/elogind start
echo "Done !"
echo "###########################################"

echo "###########################################"
echo "Installing I3"
emerge -q x11-wm/i3-gaps x11-misc/i3blocks x11-misc/i3lock x11-misc/i3status
echo "Done !"
echo "###########################################"

echo "###########################################"
echo "Configuring .xinitrc file"
echo "exec i3" >> ~/.xinitrc
echo "Done !"
echo "###########################################"

echo "###########################################"
echo "Install and configure alsa (Sound)"
emerge --ask media-sound/alsa-utils
rc-service alsasound start
rc-update add alsasound boot
alsamixer
echo "Done !"
echo "###########################################"
