#!/bin/bash
set -e

# Download source
if [ ! -e "libgit2-${LIBGIT2_VERSION}.tar.gz" ]
then
  curl $PROXY -o "libgit2-${LIBGIT2_VERSION}.tar.gz" -L "http://github.com/libgit2/libgit2/tarball/${LIBGIT2_VERSION}"
fi

# Extract source
rm -rf libgit2-libgit2-*
tar xvf "libgit2-${LIBGIT2_VERSION}.tar.gz"

# Build
pushd libgit2-libgit2-*
export CC=${DROIDTOOLS}-gcc
export LD=${DROIDTOOLS}-ld
export CPP=${DROIDTOOLS}-cpp
export CXX=${DROIDTOOLS}-g++
export AR=${DROIDTOOLS}-ar
export AS=${DROIDTOOLS}-as
export NM=${DROIDTOOLS}-nm
export STRIP=${DROIDTOOLS}-strip
export CXXCPP=${DROIDTOOLS}-cpp
export RANLIB=${DROIDTOOLS}-ranlib
export LDFLAGS="-Os -fpic -nostdlib -lc -Wl,-rpath-link=${SYSROOT}/usr/lib -L${SYSROOT}/usr/lib -L${ROOTDIR}/lib"
export CFLAGS="-Os -pipe -isysroot ${SYSROOT} -I${ROOTDIR}/include"
export CXXFLAGS="-Os -pipe -isysroot ${SYSROOT} -I${ROOTDIR}/include"

# Write a toolchain file for CMake
cat > toolchain.cmake <<EOF
SET(CMAKE_SYSTEM_NAME Linux)
SET(CMAKE_SYSTEM_VERSION Android)

SET(CMAKE_C_COMPILER   ${DROIDTOOLS}-gcc)
SET(CMAKE_CXX_COMPILER ${DROIDTOOLS}-g++)
SET(CMAKE_FIND_ROOT_PATH ${SYSROOT}/)

SET(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
SET(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
SET(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)
EOF

# Run CMake to generate the Makefiles
cmake -DCMAKE_TOOLCHAIN_FILE=toolchain.cmake -DANDROID=1 -DBUILD_CLAR=0 -DUSE_SSH=0 -DSONAME=0 \
	-DLIB_INSTALL_DIR=${ROOTDIR}/lib -DINCLUDE_INSTALL_DIR=${ROOTDIR}/include

make
make install
popd

# Clean up
rm -rf libgit2-libgit2-*

