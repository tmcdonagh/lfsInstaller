#!/bin/bash
echo "exec env -i HOME=$HOME TERM=$TERM PS1='\u:\w\$ ' /bin/bash" >> ~/.bash_profile

echo "
set +h
umask 022
LFS=/mnt/lfs
LC_ALL=POSIX
LFS_TGT=$(uname -m)-lfs-linux-gnu
PATH=/tools/bin:/bin:/usr/bin
export LFS LC_ALL LFS_TGT PATH
" >> ~/.bashrc
#source ~/.bash_profile

cd $LFS/sources
cores=$(dialog --inputbox "How many cores do you want to use for compiling?" 10 25 2>&1 > /dev/tty)

# Compiles binutils as it is needed by other packages to compile
tar -xvf binutils-2.22.tar.bz2
cd binutils-2.22.tar.bz2
mkdir -v build
cd build
time{
../configure \
  --prefix=/tools \
  --with-sysroot=$LFS \
  --with-lib-path=/tools/lib \
  --target=$LFS_TGT \
  --disable-nls \
  --disable-werror
make -j $cores
case $(uname -m) in
  x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
esac
make install
mkdir -v $LFS/sources/finished
mv $LFS/sources/binutils-2.22.tar.bz2 $LFS/sources/finished
}

# Compiles GCC and related packages
cd $LFS/sources
tar -xvf gcc-4.6.2.tar.bz2 
cd gcc-4.6.2

tar -xvf ../mpfr-3.1.0.tar.bz2
mv -v mpfr-3.1.0 mpfr
tar -xvf ../gmp-5.0.4.tar.xz
mv -v gmp-5.0.4.tar.xz gmp
tar -xvf ../mpc-1.1.0.tar.gz
mv -v mpc-1.1.0 mpc

# Moves tar files to finished directory
mv $LFS/sources/gcc-4.6.2.tar.bz2 $LFS/sources/finished
mv $LFS/sources/mpfr-3.1.0.tar.bz2 $LFS/sources/finished
mv $LFS/sources/gmp-5.0.4.tar.xz $LFS/sources/finished
mv $LFS/sources/mpc-1.1.0.tar.gz $LFS/sources/finished




