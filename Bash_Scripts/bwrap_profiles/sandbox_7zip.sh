#!/bin/sh
(exec bwrap \
--ro-bind /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu \
--ro-bind /usr/lib /usr/lib \
--symlink /lib/x86_64-linux-gnu /lib64 \
--dev /dev \
--bind /tmp /tmp \
--unshare-all \
--hostname 7zip \
--new-session \
--unsetenv XAUTHORITY \
/usr/lib/p7zip/7za "$@")
