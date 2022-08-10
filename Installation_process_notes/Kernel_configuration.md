# Kernel configuration
## Basic system configuration
```bash
-------------------
-------------------
LVM Configuration
-------------------
-------------------

-------------------
linux-4.9 Enabling LVM
Under "Device Drivers"
   Under "Multiple devices driver support (RAID and LVM)"
       <*> Device mapper support
           <*> Crypt target support
           <*> Snapshot target
           <*> Mirror target
           <*> Multipath target
               <*> I/O Path Selector based on the number of in-flight I/Os
               <*> I/O Path Selector based on the service time


-------------------
-------------------
LUKS Configuration
-------------------
-------------------

-------------------
Enabling device mapper and crypt target
[*] Enable loadable module support
Under "Device Drivers"
    [*] Multiple devices driver support (RAID and LVM) --->
        <*> Device mapper support
        <*>   Crypt target support

-------------------
Enabling cryptographic API functions
Under "Cryptographic API"
    <*> XTS support
    <*> SHA224 and SHA256 digest algorithm
    <*> AES cipher algorithms
    <*> AES cipher algorithms (x86_64)
    <*> User-space interface for hash algorithms
    <*> User-space interface for symmetric key cipher algorithms

-------------------
Enabling initramfs support
Under "General setup"
    [*] Initial RAM filesystem and RAM disk (initramfs/initrd) support

-------------------
Enabling tcrypt (TrueCrypt/tcplay/VeraCrypt compatibility mode) support
Under "Device Drivers" 
    [*] Block Devices ---> 
        <*> Loopback device support 
Under "File systems"
     <*> FUSE (Filesystem in Userspace) support 
Under "Cryptographic API" 
     <*> RIPEMD-160 digest algorithm 
     <*> SHA384 and SHA512 digest algorithms 
     <*> Whirlpool digest algorithms 
     <*> LRW support 
     <*> Serpent cipher algorithm 
     <*> Twofish cipher algorithm


-------------------
-------------------
SELinux Configuration
-------------------
-------------------

-------------------
Enabling SELinux
Under "General setup"
	[*] Auditing support
	[*] Support initial ramdisk/ramfs compressed using lZ4
Under "File systems"
  (For each file system you use, make sure extended attribute support is enabled)
	<*> Second extended fs support
	[*]   Ext2 extended attributes
	[ ]     Ext2 POSIX Access Control Lists
	[*]     Ext2 Security Labels
	<*> Ext3 journalling file system support
	[*]   Ext3 extended attributes
	[ ]     Ext3 POSIX Access Control Lists
	[*]     Ext3 Security Labels
	<*> The Extended 4 (ext4) filesystem
	[*]   Ext4 extended attributes
	[ ]     Ext4 POSIX Access Control Lists
	[*]     Ext4 Security Labels
	<*> JFS filesystem support
	[ ]   JFS POSIX Access Control Lists
	[*]   JFS Security Labels
	[ ]   JFS debugging
	[ ]   JFS statistics
	<*> XFS filesystem support
	[ ]   XFS Quota support
	[ ]   XFS POSIX ACL support
	[ ]   XFS Realtime subvolume support (EXPERIMENTAL)
	[ ]   XFS Debugging Support
	<*> Btrfs filesystem (EXPERIMENTAL)
[ ]   Btrfs POSIX Access Control Lists

Under "Security options"
	[*] Enable different security models
	[*] Socket and Networking Security Hooks
	[*] NSA SELinux Support
	[ ]   NSA SELinux boot parameter
	[ ]   NSA SELinux runtime disable
	[*]   NSA SELinux Development Support
	[ ]   NSA SELinux AVC Statistics
	(0)   NSA SELinux checkreqprot default value
		Default security module (SELinux) --->

Under "Security options"
	[*] NSA SELinux Support
	[*]   NSA SELinux boot parameter 
	(1)     NSA SELinux boot parameter default value


-------------------
-------------------
EFI stub configuration
-------------------
-------------------

-------------------
Enable EFI stub kernel
Under "Processor type and features"
    [*] EFI runtime service support 
    [*]   EFI stub support
    [*] Built-in kernel command line
	    (root=/dev/mapper/vg0-root ro dolvm crypt_root=/dev/sda2 keymap=fr)

Under "General setup"
	[*] Initial RAM filesystem and RAM disk (initramfs/initrd) support
	    (/usr/src/linux/usr/initramfs_data.cpio) Initramfs source file(s)


-------------------
-------------------
Enable wifi configuration
-------------------
-------------------

-------------------
Enable Kernel Wifi
Under "Networking support"
	Under "Networking options"
        <*> Packet socket
    Under "Wireless"
        <*> cfg80211 - wireless configuration API
```

## Hardware configuration (WIP)

## Kernel parameter to deactivate
```bash
-------------------
Disabling useless kernel components

Under "Kernel configuration"
	[] Virtualization

Under "Networking support"
	Under "Networking options"
		Under "TCP/IP Networking"
			<> The IPv6 protocol 

Under "Device Drivers"
	[] Macintosh device drivers

Under "File systems"
	[] Network File Systems
	[] Miscellaneous filesystems
	
Under "General setup"
	[] Support initial ramdisk/ramfs compressed using gzip
	[] Support initial ramdisk/ramfs compressed using gzip2
	[] Support initial ramdisk/ramfs compressed using LZMA
	[] Support initial ramdisk/ramfs compressed using XZ
	[] Support initial ramdisk/ramfs compressed using LZO
	[] Support initial ramdisk/ramfs compressed using ZSTD
```