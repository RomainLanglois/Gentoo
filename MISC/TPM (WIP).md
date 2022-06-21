# TPM (work in progress)
Trusted Platform Module (TPM) is an international standard for a secure cryptoprocessor, which is a dedicated microprocessor designed to secure hardware by integrating cryptographic keys into devices.
In practice a TPM can be used for various different security applications such as secure boot, key storage and random number generation. 

## Configure your kernel to support TPM
```bash
Device Drivers --->
    Character devices --->
    [*] TPM Hardware Support --->
        <*/M> TPM HW Random Number Generator support
        <*/M> TPM Interface Specification 1.2 Interface / TPM 2.0 FIFO Interface
        <*/M> TPM 2.0 CRB Interface
```
From :
	- https://wiki.gentoo.org/wiki/Trusted_Platform_Module

## Check if the TPM is detected
```bash
dmesg | grep -i tpm
grep -i tpm /dev/ 
```

## Installation
```bash
emerge --ask app-crypt/tpm2-tss
emerge --ask app-crypt/tpm2-tools
```

## Usage
```bash
tpm2_pcrread
```

## A word about PCR registers
Platform Configuration Registers (PCR) contain hashes that can be read at any time but can only be written via the extend operation, which depends on the previous hash value, thus making a sort of blockchain. They are intended to be used for platform hardware and software integrity checking between boots (e.g. protection against [Evil Maid attack](https://en.wikipedia.org/wiki/en:Evil_Maid_attack "wikipedia:en:Evil Maid attack")). They can be used to unlock encryption keys and proving that the correct OS was booted.

![[PCR_registers_details.png]]
From :
	- https://wiki.archlinux.org/title/Trusted_Platform_Module#Accessing_PCR_registers

## Decrypting the LUKS partition using the TPM
**Warning:** 
If you use this method on your root volume, this means that, as long as the previously mentioned certain conditions are met, your computer will **unlock automatically** at boot without needing to enter an encryption password.
	- This means that access to data is not protected in case the hardware gets stolen.
	-   Be aware that this method makes you more vulnerable to [cold boot attacks](https://en.wikipedia.org/wiki/Cold_boot_attack "wikipedia:Cold boot attack"), because even if your computer has been powered off for a long time (ensuring the memory is completely cleared), an attacker could simply turn it on and wait for the TPM to load the key automatically. This may be a concern for high-value targets.

To Read :
	- https://wiki.gentoo.org/wiki/User:Sakaki/Sakaki%27s_EFI_Install_Guide/Configuring_Secure_Boot

## A note about KVM
### vTPM (Difference between TIS and CRB model)
![[vTPM_TIS-vs-CRB_Chipset.png]]
From :
	- https://docs.openstack.org/nova/latest/admin/emulated-tpm.html

