# USE FLAG
### Why use it ?
- Unique package
- Package are less significant
- Less space used

### How to use it ?
```bash
nano /etc/portage/make.conf
	USE="-XXX" -> Remove the XXX when compiling a package
		- Example : remove systemd use flag while compiling if using OPENRC
```

### Basics commands 
Obtain descriptions and usage of the USE flag X using euse:
```bash
 euse -i X
```

Show what packages have the mysql USE flag:
```bash
 equery hasuse mysql
```

Show what packages are currently built with the mysql USE flag:
```bash
eix --installed-with-use mysql
```

Show what USE flags are available for a specific package:
```bash
equery uses <package-name>
```

Quickly add a required USE flag for a package install:
```bash
echo 'dev-util/cmake -qt5' >> /etc/portage/package.use
```

### Modify a USE flag for a specific package (Overwrite make.conf)
### /etc/portage/package.use (example with the ipv6 use flag)
```bash
toto@GentooBox ~ $ equery uses net-misc/dhcpcd
[ Legend : U - final flag setting for installation]
[        : I - package is installed with flag     ]
[ Colors : set, unset                             ]
 * Found these USE flags for net-misc/dhcpcd-9.4.1:
 U I
 - - debug    : Enable extra debug codepaths, like asserts and extra output. If you want to get meaningful
                backtraces see https://wiki.gentoo.org/wiki/Project:Quality_Assurance/Backtraces
 + + embedded : Embed the definitions of dhcp options in the dhcpcd executable 
 - - ipv6     : Add support for IP version 6
 - - privsep  : Enable support for privilege separation 
 + + udev     : Enable virtual/udev integration (device discovery, power and storage device support, etc)

toto@GentooBox ~ $ cat /etc/portage/package.use 
sys-boot/grub:2 device-mapper
net-misc/dhcpcd ipv6

toto@GentooBox ~ $ equery uses net-misc/dhcpcd
[ Legend : U - final flag setting for installation]
[        : I - package is installed with flag     ]
[ Colors : set, unset                             ]
 * Found these USE flags for net-misc/dhcpcd-9.4.1:
 U I
 - - debug    : Enable extra debug codepaths, like asserts and extra output. If you want to get meaningful
                backtraces see https://wiki.gentoo.org/wiki/Project:Quality_Assurance/Backtraces
 + + embedded : Embed the definitions of dhcp options in the dhcpcd executable 
 + - ipv6     : Add support for IP version 6
 - - privsep  : Enable support for privilege separation 
 + + udev     : Enable virtual/udev integration (device discovery, power and storage device support, etc)
```

More details here : 
- https://wiki.gentoo.org/wiki/Gentoo_Cheat_Sheet#USE_flags