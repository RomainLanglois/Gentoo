# Graphical User Interface (GUI)
## Setup make.conf file
```bash
euse -E X
euse -E alsa

portageq envvar INPUT_DEVICES
## (For mouse, keyboard, and Synaptics touchpad support)
INPUT_DEVICES="libinput synaptics"
## (For INTEL cards)
VIDEO_CARDS="intel"
```

## Remerge the packages which needs those USE flags
```bash
emerge --ask --changed-use --deep @world
```

## Install the Xorg server and make it rootless
```bash
echo "sys-auth/pambase elogind" >> /etc/portage/package.use 
emerge -q x11-base/xorg-server x11-base/xorg-drivers
env-update
source /etc/profile 
rc-update add elogind boot
/etc/init.d/elogind start
```

## Install i3 
```bash
emerge -q x11-wm/i3-gaps x11-misc/i3blocks x11-misc/i3lock x11-misc/i3status
```

## Configure .xinitrc file
```bash
echo "exec i3" >> ~/.xinitrc
```

## Install and configure alsa (Sound)
```bash
emerge --ask media-sound/alsa-utils
rc-service alsasound start
rc-update add alsasound boot
alsamixer
```


