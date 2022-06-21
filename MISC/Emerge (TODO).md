# Emerge 
## Speed up emerge times
- Reduce to the minimum the packages installed
- /etc/portage/make.conf
	- MAKEOPTS="-jX -lX ???"
	- COMMON_FLAGS="-march=native -O2 -pipe"
		- -O2 is the fastest and safest option
			- -O3 can be used but very dangerous, some packages will not compile correclty
		- -pipe : this option needs a lot of RAM (2GB per CPU threads)
	- PORTAGE_NICENESS=1 ???
- Use ccache directory ??