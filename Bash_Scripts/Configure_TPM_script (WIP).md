```bash
# Check if script runs as the root user

# Check if a TPM device exits
dmesg | grep -i tpm
grep -i tpm /dev/ 

# Check if the kernel is correctly configure ?
grep -i <some_kernel_parameters> /usr/src/linux/.config

emerge --ask app-crypt/tpm2-tss
emerge --ask app-crypt/tpm2-tools

eselect repository enable guru
emerge --sync
emerge --ask app-crypt/clevis

tpm2_pcrread

cryptsetup luksDump /dev/nvme0n1p3
clevis luks bind -d /dev/nvme0n1p3 tpm2 '{"pcr_bank":"sha256","pcr_ids":"0,2,3,5,6,7"}'

cryptsetup luksDump /dev/nvme0n1p3

# Support to Clevis to add
mount /dev/sda2 /boot
genkernel --luks --lvm initramfs
```