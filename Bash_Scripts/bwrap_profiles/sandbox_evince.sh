exec bwrap \
   --ro-bind /usr/bin/evince /usr/bin/evince \
   --ro-bind /lib/x86_64-linux-gnu /lib/x86_64-linux-gnu \
   --ro-bind /usr /usr \
   --ro-bind /var /var \
   --symlink /lib/x86_64-linux-gnu /lib64 \
   --ro-bind $HOME/Documents $HOME/Documents \
   --ro-bind $HOME/.Xauthority $HOME/.Xauthority \
   --ro-bind /etc/fonts /etc/fonts \
   --ro-bind /tmp/.X11-unix/X0 /tmp/.X11-unix/X0 \
   --unshare-all \
   --new-session \
/usr/bin/evince "$@"
