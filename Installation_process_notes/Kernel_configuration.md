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
## Make TTY work
CONFIG_VGA_CONSOLE=y
CONFIG_DUMMY_CONSOLE=y
CONFIG_DUMMY_CONSOLE_COLUMNS=80
CONFIG_DUMMY_CONSOLE_ROWS=25
CONFIG_FRAMEBUFFER_CONSOLE=y
CONFIG_FRAMEBUFFER_CONSOLE_DETECT_PRIMARY=y

## Hardware configuration
### T560
#### LSPCI
- Host bridge: Intel Corporation Xeon E3-1200 v5/E3-1500 v5/6th Gen Core Processor Host Bridge/DRAM Registers
	- https://linux-hardware.org/index.php?id=pci:8086-1910-1462-115b
	- CONFIG_CPU_SUP_INTEL
	- CONFIG_PERF_EVENTS
	- CONFIG_PERF_EVENTS_INTEL_UNCORE
	- skl_uncore -> lspci -k
- VGA compatible controller: Intel Corporation Skylake GT2 [HD Graphics 520]
	- https://linux-hardware.org/index.php?id=pci:8086-1916-103c-80fd
	- CONFIG_DRM_I915
	- CONFIG_PCI
	- CONFIG_SND
	- CONFIG_SND_HDA_CORE
	- CONFIG_SND_HDA_I915
	- i915 -> lspci -k
- System peripheral: Intel Corporation Xeon E3-1200 v5/v6 / E3-1500 v5 / 6th/7th/8th Gen Core Processor Gaussian Mixture Model
	- https://linux-hardware.org/index.php?id=pci:8086-1911-8086-2064
	- No drivers !
- USB controller: Intel Corporation Sunrise Point-LP USB 3.0 xHCI Controller
	- https://linux-hardware.org/index.php?id=pci:8086-9d2f-1028-0768
	- CONFIG_PCI
	- CONFIG_USB
	- CONFIG_USB_EHCI_HCD
	- CONFIG_USB_FHCI_HCD
	- CONFIG_USB_HWA_HCD
	- CONFIG_USB_ISP116X_HCD
	- CONFIG_USB_ISP1760_HCD
	- CONFIG_USB_OHCI_HCD
	- CONFIG_USB_R8A66597_HCD
	- CONFIG_USB_SL811_HCD
	- CONFIG_USB_U132_HCD
	- CONFIG_USB_UHCI_HCD
	- CONFIG_USB_XHCI_HCD
	- xhci_pci -> lspci -k
- Signal processing controller: Intel Corporation Sunrise Point-LP Thermal subsystem
	- https://linux-hardware.org/index.php?id=pci:8086-9d31-103c-81ec
	- CONFIG_THERMAL
	- CONFIG_INTEL_PCH_THERMAL
	- intel_pch_thermal -> lspci -k
- Communication controller: Intel Corporation Sunrise Point-LP CSME HECI
	- https://linux-hardware.org/?id=pci:8086-9d3a-1028-075b
	- CONFIG_INTEL_MEI
	- CONFIG_INTEL_MEI_ME
	- mei_me -> lspci -k
- SATA controller: Intel Corporation Sunrise Point-LP SATA Controller [AHCI mode]
	- https://linux-hardware.org/?id=pci:8086-9d03-1043-1b00
	- CONFIG_ATA
	- CONFIG_SATA_AHCI
	- ahci -> lspci -k
- PCI bridge: Intel Corporation Sunrise Point-LP PCI Express Root Port #1/#3/#9
	- https://linux-hardware.org/?id=pci:8086-9d10-1043-1d30
	- CONFIG_PCI
	- CONFIG_PCIEPORTBUS
	- pcieport -> lspci -k
- ISA bridge: Intel Corporation Sunrise Point-LP LPC Controller
	- No drivers !
- Memory controller: Intel Corporation Sunrise Point-LP PMC
	- No drivers !
- Audio device: Intel Corporation Sunrise Point-LP HD Audio
	- https://linux-hardware.org/index.php?id=pci:8086-9d71-17aa-2249
	- CONFIG_SND
	- CONFIG_SND_SOC
	- CONFIG_SND_SOC_INTEL_SKYLAKE
	- snd_hda_intel, snd_soc_skl -> lspci -k
- SMBus: Intel Corporation Sunrise Point-LP SMBus
	- https://linux-hardware.org/?id=pci:8086-9d23-1458-1000
	- CONFIG_I2C_I801
	- i2c_i801 -> lspci -k
- Ethernet controller: Intel Corporation Ethernet Connection I219-LM
	- https://linux-hardware.org/?id=pci:8086-15bb-103c-83e0
	- CONFIG_E1000E
	- CONFIG_ETHERNET
	- CONFIG_NET_VENDOR_INTEL
	- e1000e -> lspci -k
- Network controller: Intel Corporation Wireless 8260
	- https://linux-hardware.org/?id=pci:8086-24f3-8086-0130
	- CONFIG_IWLWIFI
	- CONFIG_WLAN
	- CONFIG_WLAN_VENDOR_INTEL
	- CONFIG_THINKPAD_ACPI
	- CONFIG_X86
	- iwlwifi -> lspci -k
- 3D controller: NVIDIA Corporation GM108M [GeForce 940MX]
	- Nouveau OR Nvidia proprietary
	- nouveau -> lspci -k

#### LSUSB
- Bus 001 Device 002: ID 5986:0706 Acer, Inc ThinkPad P50 Integrated Camera
	- https://linux-hardware.org/?id=usb:5986-0706
	- CONFIG_USB_VIDEO_CLASS
- Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub
	- https://linux-hardware.org/?id=usb:1d6b-0002
	- CONFIG_USB
- Bus 002 Device 002: ID 0781:5581 SanDisk Corp. Ultra
	- https://linux-hardware.org/?id=usb:0781-5581
	- CONFIG_PCI
	- CONFIG_USB

### V330-14IKB (TODO)
#### LSPCI

#### LSUSB

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
