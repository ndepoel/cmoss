#!/bin/bash
set -e

# Retrieve NDK path to use
NDK=$1
if [ "${NDK}" == "" ] || [ ! -e ${NDK}/build/tools/make-standalone-toolchain.sh ]
then
  echo "Please specify a valid NDK path."
  exit 1
fi

export SDK="${NDK}"

if [ -z $2 ]
then
	export PROXY=""
else
	export PROXY="-x $2"
fi

# Compilation options for libgit2
LIBGIT2_WITH_SSL=true
LIBGIT2_WITH_SSH=false
LIBGIT2_LINK_DYNAMIC=false

# Project version to use to build minizip (changing this may break the build)
export MINIZIP_VERSION="11"

# Project version to use to build icu (changing this may break the build)
#export ICU_VERSION="4.8.1.1"
export ICU_VERSION="50.1.1"

# Project version to use to build c-ares (changing this may break the build)
export CARES_VERSION="1.9.1"

# Project version to use to build bzip2 (changing this may break the build)
export BZIP2_VERSION="1.0.6"

# Project version to use to build libidn (changing this may break the build)
export LIBIDN_VERSION="1.26"

# GNU Crypto libraries
export LIBGPG_ERROR_VERSION="1.12"
export LIBGCRYPT_VERSION="1.6.1"
export GNUPG_VERSION="1.4.16"

# Project versions to use to build openssl (changing this may break the build)
export OPENSSL_VERSION="1.0.1g"

# Project versions to use to build libssh2 and cURL (changing this may break the build)
export LIBSSH2_VERSION="1.4.3"
export CURL_VERSION="7.28.1"

# Project Version to use to build libgsasl
export LIBGSASL_VERSION="1.8.0"

# Project version to use to build boost C++ libraries
export BOOST_VERSION="1.52.0"
export BOOST_LIBS="chrono context date_time exception filesystem graph graph_parallel iostreams mpi program_options random regex serialization signals system test thread timer wave"

# Project version to use to build tinyxml
export TINYXML_VERSION="2.6.2"
export TINYXML_FILE="2_6_2"

# Project version to use to build expat (changing this may break the build)
export EXPAT_VERSION="2.0.1"

# Project version to use to build yajl (changing this may break the build)
export YAJL_VERSION="2.0.3"

# Project version to use to build sqlcipher (changing this may break the build)
export SQLCIPHER_VERSION="2.1.1"

# Project versions to use for SOCI (Sqlite3 C++ database library)
export SOCI_VERSION="3.1.0"

# Project version to use to build pion (changing this may break the build)
export PION_VERSION="master"

# Project version to use to build libgit2
export LIBGIT2_VERSION="development"

# Create dist folder
BUILDDIR=$(dirname $0)

pushd $BUILDDIR
export TOPDIR=$(dirname $(pwd))
export BINDIR=$TOPDIR/bin/droid
export LOGDIR=$TOPDIR/log/droid
export TMPDIR=$TOPDIR/tmp
popd

rm -rf $LOGDIR
mkdir -p $LOGDIR
mkdir -p $TMPDIR

pushd $TMPDIR

export ANDROID_API_LEVEL="9"
export ARM_TARGET="armv7"

if [ -z $TOOLCHAIN_VERSION ]
then
	export TOOLCHAIN_VERSION="4.8"
fi

# Platforms to build for (changing this may break the build)
PLATFORMS="arm-linux-androideabi x86"

# Create tool chains for each supported platform
for PLATFORM in ${PLATFORMS}
do
	echo "Creating toolchain for platform ${PLATFORM}..."

	if [ ! -d "${TMPDIR}/droidtoolchains/${PLATFORM}" ]
	then
		$NDK/build/tools/make-standalone-toolchain.sh \
			--verbose \
			--platform=android-${ANDROID_API_LEVEL} \
			--toolchain=${PLATFORM}-${TOOLCHAIN_VERSION} \
			--install-dir=${TMPDIR}/droidtoolchains/${PLATFORM}
	fi
done

# Build projects
for PLATFORM in ${PLATFORMS}
do
	LOGPATH="${LOGDIR}/${PLATFORM}"
	ROOTDIR="${TMPDIR}/build/droid/${PLATFORM}"

	mkdir -p "${ROOTDIR}"

	if [ "${PLATFORM}" == "arm-linux-androideabi" ]
	then
		export ARCH=${ARM_TARGET}
		export TOOLSPREFIX=${PLATFORM}
	else
		export ARCH="x86"
		export TOOLSPREFIX="i686-linux-android"
	fi

	export ROOTDIR=${ROOTDIR}
	export PLATFORM=${PLATFORM}
	export DROIDTOOLS=${TMPDIR}/droidtoolchains/${PLATFORM}/bin/${TOOLSPREFIX}
	export SYSROOT=${TMPDIR}/droidtoolchains/${PLATFORM}/sysroot

	# Build minizip
	#${TOPDIR}/build-droid/build-minizip.sh > "${LOGPATH}-minizip.log"

	# Build icu
	#${TOPDIR}/build-droid/build-icu.sh > "${LOGPATH}-icu.log"

	# Build c-ares
	#${TOPDIR}/build-droid/build-cares.sh > "${LOGPATH}-cares.log"

	# Build bzip2
	#${TOPDIR}/build-droid/build-bzip2.sh > "${LOGPATH}-bzip2.log"

	# Build libidn (before curl and gsasl)
	#${TOPDIR}/build-droid/build-libidn.sh > "${LOGPATH}-libidn.log"

	# Build libgpg-error
	${TOPDIR}/build-droid/build-libgpg-error.sh > "${LOGPATH}-libgpg-error.log"

	# Build libgcrypt
	${TOPDIR}/build-droid/build-libgcrypt.sh > "${LOGPATH}-libgcrypt.log"

	# Build GnuPG
	${TOPDIR}/build-droid/build-GnuPG.sh > "${LOGPATH}-GnuPG.log"

	# Build OpenSSL
	${TOPDIR}/build-droid/build-openssl.sh > "${LOGPATH}-OpenSSL.log"

	if [ "$LIBGIT2_WITH_SSH" == "true" ];
	then
		# Build libssh2
		${TOPDIR}/build-droid/build-libssh2.sh > "${LOGPATH}-libssh2.log"
	fi

	# Build cURL
	#${TOPDIR}/build-droid/build-cURL.sh > "${LOGPATH}-cURL.log"

	# Build libgsasl
	#${TOPDIR}/build-droid/build-libgsasl.sh > "${LOGPATH}-libgsasl.log"

	# Build BOOST
	#${TOPDIR}/build-droid/build-boost.sh > "${LOGPATH}-boost.log"

	# Build tinyxml
	#${TOPDIR}/build-droid/build-tinyxml.sh > "${LOGPATH}-tinyxml.log"

	# Build expat
	#${TOPDIR}/build-droid/build-expat.sh > "${LOGPATH}-expat.log"

	# Build yajl
	#${TOPDIR}/build-droid/build-yajl.sh > "${LOGPATH}-yajl.log"

	# Build SQLCipher
	#${TOPDIR}/build-droid/build-sqlcipher.sh > "${LOGPATH}-sqlcipher.log"

	# Build SOCI
	#${TOPDIR}/build-droid/build-soci.sh > "${LOGPATH}-soci.log"

	# Build PION
	#${TOPDIR}/build-droid/build-pion.sh > "${LOGPATH}-pion.log"

	# Make the previously built libraries available to libgit2
	if [ "$LIBGIT2_WITH_SSL" == "true" ];
	then
		cp -r ${ROOTDIR}/include ${SYSROOT}/usr/

		cp ${ROOTDIR}/lib/*.a ${SYSROOT}/usr/lib
		cp ${ROOTDIR}/lib/*.la ${SYSROOT}/usr/lib
		if [ "$LIBGIT2_LINK_DYNAMIC" == "true" ];
		then
			(cd ${ROOTDIR}/lib && tar cf - *.so ) | ( cd ${SYSROOT}/usr/lib && tar xfB - )
		fi
	fi

	# Build libgit2
	${TOPDIR}/build-droid/build-libgit2.sh > "${LOGPATH}-libgit2.log"

	# Remove junk
	rm -rf "${ROOTDIR}/bin"
	rm -rf "${ROOTDIR}/certs"
	rm -rf "${ROOTDIR}/libexec"
	rm -rf "${ROOTDIR}/man"
	rm -rf "${ROOTDIR}/misc"
	rm -rf "${ROOTDIR}/private"
	rm -rf "${ROOTDIR}/sbin"
	rm -rf "${ROOTDIR}/share"
	rm -rf "${ROOTDIR}/openssl.cnf"

	# Copy headers to platform-specific include dir
	mkdir -p ${BINDIR}/${ARCH}/include
	cp -r ${ROOTDIR}/include ${BINDIR}/${ARCH}/

	# Copy libraries to platform-specific lib dir
	mkdir -p ${BINDIR}/${ARCH}/lib
	cp ${ROOTDIR}/lib/*.a ${BINDIR}/${ARCH}/lib
	cp ${ROOTDIR}/lib/*.la ${BINDIR}/${ARCH}/lib
	(cd ${ROOTDIR}/lib && tar cf - *.so ) | ( cd ${BINDIR}/${ARCH}/lib && tar xfB - )
done

echo "**** Android c/c++ open source build completed ****"

popd
