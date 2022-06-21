# TODO
0) Know how to configure your own make.conf file
        - MAKEOPTS
        - COMMON_FLAGS
        - USE flags
        - GRUB_PLATFORM
        - GENTOO_MIRRORS
        - https://wiki.gentoo.org/wiki/Handbook:AMD64/Installation/Stage#Configuring_compile_options
1) Find the  procedure to encrypt the HDD (luks)
	- https://wiki.gentoo.org/wiki/Full_Disk_Encryption_From_Scratch_Simplified
2) Test UEFI install
3) ) Portage Usage
4) Have some scripts to install automatically gentoo
5) Know how to customize and compile your own kernel
6) Install, configure and test selinux
7) LUKS TPM ?

# Prepa kernel
```bash
GentooBox /usr/src/linux # lspci
00:00.0 Host bridge: Intel Corporation 82G33/G31/P35/P31 Express DRAM Controller
00:01.0 VGA compatible controller: Red Hat, Inc. QXL paravirtual graphic card (rev 05)
00:02.0 PCI bridge: Red Hat, Inc. QEMU PCIe Root port
00:02.1 PCI bridge: Red Hat, Inc. QEMU PCIe Root port
00:02.2 PCI bridge: Red Hat, Inc. QEMU PCIe Root port
00:02.3 PCI bridge: Red Hat, Inc. QEMU PCIe Root port
00:02.4 PCI bridge: Red Hat, Inc. QEMU PCIe Root port
00:02.5 PCI bridge: Red Hat, Inc. QEMU PCIe Root port
00:1b.0 Audio device: Intel Corporation 82801I (ICH9 Family) HD Audio Controller (rev 03)
00:1f.0 ISA bridge: Intel Corporation 82801IB (ICH9) LPC Interface Controller (rev 02)
00:1f.2 SATA controller: Intel Corporation 82801IR/IO/IH (ICH9R/DO/DH) 6 port SATA Controller [AHCI mode] (rev 02)
00:1f.3 SMBus: Intel Corporation 82801I (ICH9 Family) SMBus Controller (rev 02)
01:00.0 Ethernet controller: Intel Corporation 82574L Gigabit Network Connection
02:00.0 USB controller: Red Hat, Inc. QEMU XHCI Host Controller (rev 01)
03:00.0 Communication controller: Red Hat, Inc. Virtio console (rev 01)
04:00.0 Unclassified device [00ff]: Red Hat, Inc. Virtio memory balloon (rev 01)
05:00.0 Unclassified device [00ff]: Red Hat, Inc. Virtio RNG (rev 01)

GentooBox /usr/src/linux # lsusb
Bus 002 Device 001: ID 1d6b:0003 Linux Foundation 3.0 root hub
Bus 001 Device 002: ID 0627:0001 Adomax Technology Co., Ltd QEMU USB Tablet
Bus 001 Device 001: ID 1d6b:0002 Linux Foundation 2.0 root hub

GentooBox /usr/src/linux # lsmod
Module                  Size  Used by
vfat                   20480  1
fat                    86016  1 vfat
cfg80211             1036288  0
rfkill                 32768  1 cfg80211
8021q                  40960  0
garp                   16384  1 8021q
mrp                    20480  1 8021q
stp                    16384  1 garp
llc                    16384  2 stp,garp
intel_rapl_msr         20480  0
intel_rapl_common      28672  1 intel_rapl_msr
intel_pmc_core_pltdrv    16384  0
intel_pmc_core         53248  0
kvm_intel             274432  0
snd_hda_codec_generic    98304  1
ledtrig_audio          16384  1 snd_hda_codec_generic
snd_hda_intel          57344  0
snd_intel_dspcfg       28672  1 snd_hda_intel
kvm                  1040384  1 kvm_intel
snd_intel_sdw_acpi     20480  1 snd_intel_dspcfg
irqbypass              16384  1 kvm
crct10dif_pclmul       16384  1
qxl                    77824  0
snd_hda_codec         176128  2 snd_hda_codec_generic,snd_hda_intel
drm_ttm_helper         16384  1 qxl
ttm                    86016  2 qxl,drm_ttm_helper
ghash_clmulni_intel    16384  0
snd_hda_core          110592  3 snd_hda_codec_generic,snd_hda_intel,snd_hda_codec
rapl                   20480  0
drm_kms_helper        307200  3 qxl
snd_hwdep              16384  1 snd_hda_codec
cec                    61440  1 drm_kms_helper
iTCO_wdt               16384  0
rc_core                65536  1 cec
snd_pcm               143360  3 snd_hda_intel,snd_hda_codec,snd_hda_core
iTCO_vendor_support    16384  1 iTCO_wdt
snd_timer              49152  1 snd_pcm
drm                   634880  5 drm_kms_helper,qxl,drm_ttm_helper,ttm
snd                   114688  6 snd_hda_codec_generic,snd_hwdep,snd_hda_intel,snd_hda_codec,snd_timer,snd_pcm
i2c_i801               32768  0
lpc_ich                28672  0
pcspkr                 16384  0
serio_raw              20480  0
efi_pstore             16384  0
joydev                 28672  0
i2c_smbus              20480  1 i2c_i801
soundcore              16384  1 snd
backlight              24576  2 drm_kms_helper,drm
mfd_core               20480  1 lpc_ich
i2c_core              102400  4 drm_kms_helper,i2c_smbus,i2c_i801,drm
mac_hid                16384  0
qemu_fw_cfg            20480  0
efivarfs               16384  1
ext4                  925696  2
mbcache                16384  1 ext4
jbd2                  167936  1 ext4
dm_crypt               61440  1
trusted                36864  1 dm_crypt
asn1_encoder           16384  1 trusted
dm_mod                176128  10 dm_crypt
sr_mod                 28672  0
sd_mod                 61440  2
cdrom                  77824  1 sr_mod
t10_pi                 16384  1 sd_mod
xhci_pci               20480  0
crc32_pclmul           16384  0
ahci                   45056  2
xhci_pci_renesas       20480  1 xhci_pci
crc32c_intel           24576  4
libahci                45056  1 ahci
e1000e                319488  0
xhci_hcd              327680  1 xhci_pci
```