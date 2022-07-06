# Configure SELinux
## Configuration when using a Hardened/SELinux profile
#### Preparing the system and labelling it:
```bash
# Those commands can be used when configuring a SELINUXTYPE to strict 
# More details here :
	# - https://wiki.gentoo.org/wiki/SELinux/Installation#Relabel
mkdir /mnt/gentoo 
mount -o bind / /mnt/gentoo
# In the following command, substitute _strict_ in the next command with _targeted_ (or other policy store name) depending on the `SELINUXTYPE` value. If your system has more active mountpoints than the usual set of /dev,/home,/proc,/run,/sys,/tmp, list them too.
setfiles -r /mnt/gentoo /etc/selinux/strict/contexts/files/file_contexts /mnt/gentoo/{dev,home,proc,run,sys,tmp} 
umount /mnt/gentoo
rlpkg -a -r
```

#### Assigning SELinux user to Linux user
```bash
semanage login -a -s staff_u <username> 
restorecon -R -F /home/john

# If needed to change the user current role
user $id -Z
staff_u:staff_r:staff_t

user $newrole -r sysadm_r
Password: (Enter your password)

user $id -Z
staff_u:sysadm_r:sysadm_t
```

## SELinux custom policies (WIP)