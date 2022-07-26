# Gentoo Important details to know before installing
- Not a binary distribution (you have to compile your packages)
	- Firefox can take multiple hours to compile
- Time consuming 
- Lot of architectures (MIPS, ARM, SPARC, x86, amd64, etc.)
- Possible to customize your kernel
	- Ex : remove bluetooth support before compiling the kernel
- Possible to customize what are installed on your system
- Package manager : Portage
	- Build package based on the diectives you put inside the make.conf file
- USE flag are a critical component of the gentoo environnement (specify what you want and don't want to compile)
	- Ex: remove bluetooth support when compiling a package
- Use specific flag for your compiler to optimize the compilation process for your architecture
- Be prepare to debug and RESCUE a broken system !
	- Reinstall a system == RECOMPILE everything !!
	
# TODO
- Install and configure secure boot
- Customize and upload the kernel config file
		- Create a script which handles this process
