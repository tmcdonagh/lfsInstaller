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

# Brings partitioning utility up
cfdisk $mainDrive
while :
do
  part=$(dialog --inputbox "What is the root partition?\n (i.e. /dev/sda1)" 10 25 --output-fd 1)
  dialog --yesno "Do you have a swap partition?" 10 30
  if [ $? == 0 ] 
  then
    swap=$(dialog --inputbox "What is your swap partition?\n (i.e. /dev/sda)" --output-fd 1)
  else
    swap="None"
  fi
  dialog --yesno "Is this correct\n Root = $part \n Swap = $swap" 10 30
  if [ $? == 0 ]
  then
    break
  fi
done
