#!/bin/bash
# Installs required packages
sudo apt install dialog \
       vim \
       binutils \
       bison \
       bzip2 \
       coreutils \
       diffutils \
       findutils \
       gawk \
       gcc \
       grep \
       gzip 
# Updates and upgrades packages
sudo apt update && sudo apt upgrade

while :
do
	sudo fdisk -l
	echo "
	
	
	${bold}What drive do you want to use (i.e. /dev/sda)
	
	
	"
	read mainDrive
	dialog \
		--yesno "\nIs $mainDrive correct?" 10 30
	if [ $? == 0 ]
	then
		break
	fi
done

echo $mainDrive

