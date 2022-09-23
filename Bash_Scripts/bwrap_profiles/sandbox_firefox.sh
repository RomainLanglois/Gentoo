#!/usr/bin/env bash
exec bwrap \
  --ro-bind /bin /bin \
  --ro-bind /opt/firefox /opt/firefox \
  --ro-bind /usr/share /usr/share/ \
  --ro-bind /usr/lib /usr/lib \
  --ro-bind /usr/lib64 /usr/lib64 \
  --ro-bind /lib64 /lib64 \
  --ro-bind /etc /etc \
  --ro-bind /usr/bin /usr/bin \
  --proc /proc \
  --dev /dev \
  --tmpfs /run \
  --ro-bind /run/user/"$(id -u)"/wayland-1 /run/user/"$(id -u)"/wayland-1 \
  --ro-bind /run/user/"$(id -u)"/pulse /run/user/"$(id -u)"/pulse \
  --bind ~/Downloads/firefox ~/Downloads \
  --bind ~/.mozilla ~/.mozilla \
  --bind ~/.cache/mozilla ~/.cache/mozilla \
  --unsetenv DBUS_SESSION_BUS_ADDRESS \
  --setenv MOZ_ENABLE_WAYLAND 1 \
  --unshare-all \
  --share-net \
  --hostname firefox \
  --new-session \
/opt/firefox/firefox-bin
