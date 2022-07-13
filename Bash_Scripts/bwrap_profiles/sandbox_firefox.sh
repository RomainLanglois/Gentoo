#!/bin/sh

exec bwrap \
    --proc /proc \
    --dev /dev \
    --ro-bind /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu \
    --ro-bind /usr /usr \
    --ro-bind /etc /etc \
    --ro-bind /run /run \
    --ro-bind /var /var \
    --ro-bind ~/.Xauthority ~/.Xauthority \
    --bind ~/.cache/mozilla ~/.cache/mozilla \
    --bind ~/.mozilla ~/.mozilla \
    --bind ~/Téléchargements ~/Téléchargements \
    --dev-bind /dev/snd /dev/snd \
    --symlink /lib/x86_64-linux-gnu /lib64 \
    --unshare-all \
    --share-net \
    --hostname RESTRICTED \
    --new-session \
 /usr/lib/firefox/firefox "$@"


# /run -> partie réseau
# /var -> partie fichier temporaire
