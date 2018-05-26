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
sudo cfdisk $mainDrive
while :
do
  part=$(dialog --inputbox "What is the root partition?\n (i.e. /dev/sda1)" 10 25 --output-fd 1)
  dialog --yesno "Do you have a swap partition?" 10 30
  if [ $? == 0 ] 
  then
    swap=$(dialog --inputbox "What is your swap partition?\n (i.e. /dev/sda2)" 10 25 --output-fd 1)
  else
    swap="None"
  fi
  dialog --yesno "Is this correct\n Root = $part \n Swap = $swap" 10 30
  if [ $? == 0 ]
  then
    break
  fi
done
# Formats root partition as ext4
sudo mkfs -v -t ext4 $part
# If swap is present format swap
if [ $swap != "None" ]
then
  sudo mkswap $swap
  sudo /sbin/swapon -v $swap
fi
export LFS=/mnt/lfs
sudo mkdir -pv $LFS
sudo mount -v -t ext4 $part $LFS
sudo mkdir -v $LFS/sources
sudo chmod -v a+wt $LFS/sources
sudo wget --input-file=wget-list -continue --directory-prefix=$LFS/sources
sudo mkdir -v $LFS/tools
ln -sv $LFS/tools /
sudo groupadd lfs
sudo useradd -s /bin/bash -g lfs -m -k /dev/null lfs
echo "



Input Password for lfs user



"
sudo passwd lfs
sudo chown -v lfs $LFS/tools
sudo chown -v lfs $LFS/sources
su - lfs
echo test
