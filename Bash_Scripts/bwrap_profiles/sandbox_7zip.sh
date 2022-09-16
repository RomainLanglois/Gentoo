#!/bin/bash
exec bwrap \
	--ro-bind /usr/lib64/p7zip/7za /usr/lib64/p7zip/7za \
	--ro-bind /usr/lib /usr/lib \
	--ro-bind /lib64 /lib64 \
	--ro-bind /etc /etc \
	--dev /dev \
	--bind ~/Documents/archives ~ \
	--unshare-all \
	--hostname p7zip \
	--unsetenv XAUTHORITY \
	--new-session \
/usr/lib64/p7zip/7za "$@"
