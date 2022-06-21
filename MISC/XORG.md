# XORG Install
```bash
`/etc/portage/make.conf`
USE="X"

portageq envvar INPUT_DEVICES

## (For mouse, keyboard, and Synaptics touchpad support)
INPUT_DEVICES="libinput synaptics"
## (For INTEL cards)
VIDEO_CARDS="intel"

emerge --ask x11-base/xorg-server
env-update
source /etc/profile 

emerge --ask x11-wm/i3
emerge --ask x11-misc/i3blocks
emerge --ask x11-misc/i3lock

nano ~/.xinitrc
exec i3
```
