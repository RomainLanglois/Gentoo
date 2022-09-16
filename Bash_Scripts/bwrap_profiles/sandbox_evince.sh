#!/bin/bash
exec bwrap \
     --ro-bind /usr/bin/evince /usr/bin/evince \
     --ro-bind /usr/lib64 /usr/lib64 \
     --ro-bind /lib64 /lib64 \
     --ro-bind /usr/lib /usr/lib \
     --ro-bind /usr/share /usr/share \
     --ro-bind /etc /etc \
     --ro-bind ~/Documents/pdf ~ \
     --proc /proc \
     --dev /dev \
     --ro-bind /run/user/"$(id -u)"/wayland-1 /run/user/"$(id -u)"/wayland-1 \
     --ro-bind ~/.cache/fontconfig ~/.cache/fontconfig \
     --ro-bind "${@: -1}" ~/"$(basename "${@: -1}")" \
     --chdir ~/ \
     --unshare-all \
     --new-session \
/usr/bin/evince "$@"
