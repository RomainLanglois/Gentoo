# Bash one liner to retrieve and format all packages inside the world file
# while read -r line; do echo "\"$line\""; done < /var/lib/portage/world

## Add support for the TPM
TPM_softwares_array=(
"app-crypt/clevis"
"app-crypt/tpm2-tools"
"app-crypt/tpm2-tss"
)

softwares_array=(
"app-eselect/eselect-repository"
"app-misc/neofetch"
"app-portage/gentoolkit"
"dev-vcs/git"
"sys-apps/usbutils"
"sys-process/htop"
"app-arch/lz4"
)

emaint -a sync
for software in ${softwares_array[@]}; do
  emerge -q $software
done

echo "Do you wan to install the TPM packages ? (Y/N)"
read user_choice
if [[ $user_choice = "Y" ]]
then
	for TPM_software in ${TPM_softwares_array[@]}; do
	  emerge -q $TPM_software
	done
else
	echo "Exiting..."
fi
