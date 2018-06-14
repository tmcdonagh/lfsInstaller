#!/bin/bash
LFS=/mnt/lfs
sudo ls
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
tar -xf binutils-2.22.tar.bz2
cd binutils-2.22
mkdir -v build
cd build
time {
../configure \
  --prefix=/tools \
  --with-sysroot=$LFS \
  --with-lib-path=/tools/lib \
  --target=$LFS_TGT \
  --disable-nls \
  --disable-werror &&
  make -j $cores &&

  case $(uname -m) in
    x86_64) mkdir -v /tools/lib && ln -sv lib /tools/lib64 ;;
  esac  
  make install ;
}
mkdir -v $LFS/sources/finished
mv $LFS/sources/binutils-2.22.tar.bz2 $LFS/sources/finished

# Compiles GCC and related packages
cd $LFS/sources
tar -xf gcc-4.6.2.tar.bz2 
cd gcc-4.6.2

tar -xf ../mpfr-3.1.0.tar.bz2
sudo mv -v mpfr-3.1.0 mpfr
tar -xf ../gmp-5.0.4.tar.xz
sudo mv -v gmp-5.0.4.tar.xz gmp
tar -xf ../mpc-1.1.0.tar.gz
sudo mv -v mpc-1.1.0 mpc

# Debugging
sleep 10

# Moves tar files to finished directory
sudo mv $LFS/sources/gcc-4.6.2.tar.bz2 $LFS/sources/finished
sudo mv $LFS/sources/mpfr-3.1.0.tar.bz2 $LFS/sources/finished
sudo mv $LFS/sources/gmp-5.0.4.tar.xz $LFS/sources/finished
sudo mv $LFS/sources/mpc-1.1.0.tar.gz $LFS/sources/finished

for file in gcc/config/{linux,i386/linux{,64}}.h
do
  cp -uv $file{,.orig}
  sed -e 's@/lib\(64\)\?\(32\)\?/ld@/tools&@g' \
    -e 's@/usr@/tools@g' $file.orig > $file
  echo '
  #undef STANDARD_STARTFILE_PREFIX_1
  #undef STANDARD_STARTFILE_PREFIX_2
  #define STANDARD_STARTFILE_PREFIX_1 "/tools/lib/"
  #define STANDARD_STARTFILE_PREFIX_2 ""' >> $file
  touch $file.orig
done

case $(uname -m) in
  x86_64)
    sed -e '/m64=/s/lib64/lib/' \
      -i.orig gcc/config/i386/t-linux64
    ;;
esac

time {
mkdir -v build &&
  cd build &&
  ../configure \
  --target=$LFS_TGT \
  --prefix=/tools \
  --with-glibc-version=2.11 \
  --with-sysroot=$LFS \
  --with-newlib \
  --without-headers \
  --with-local-prefix=/tools \
  --with-native-system-header-dir=/tools/include \
  --disable-nls \
  --disable-shared \
  --disable-multilib \
  --disable-decimal-float \
  --disable-threads \
  --disable-libatomic \
  --disable-libgomp \
  --disable-libmpx \
  --disable-libquadmath \
  --disable-libssp \
  --disable-libvtv \
  --disable-libstdcxx \
  --enable-languages=c,c++ &&
  make -j $cores &&
  make install ;
}
