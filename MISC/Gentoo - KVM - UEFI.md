# When Trying to install Gentoo with UEFI support using KVM
- https://bugs.launchpad.net/nova/+bug/1831538
- https://forums.gentoo.org/viewtopic-t-1066336-start-0.html
- Use Firmware : OVMF_CODE.fd
- Use Chipset : Q35
        - Caution : Q35 chipset does not support IDE connection, only SATA and SCSI
        - It is necessary to remove all IDE connectors and replace them with SATA or SCSI
- ls /sys/firmware/efi
        - Check if you are using UEFI