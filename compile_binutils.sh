#!/bin/bash

TARGET_ARCH=$1
if [ -z "${TARGET_ARCH}" ]; then
    echo "Error: Please pass the desired arch, i.e., i386, x86_64, aarch64"
    exit 1
fi
if [[ "$TARGET_ARCH" == *"-"* ]]; then
  FULL_TRIPLET="${TARGET_ARCH}"
else
  FULL_TRIPLET="${TARGET_ARCH}-unknown-linux-gnu"
fi
echo "[+] build for ${FULL_TRIPLET}"

BINUTILS_VERSION="${2:-2.42}"
echo "[+] using binutils ${BINUTILS_VERSION}"

UNAME_M=$(uname -m)
HOST_ARCH="${3:-$UNAME_M}"
HOST_SYSTEM=$4
HOST_TRIPLET="${HOST_ARCH}-${HOST_SYSTEM}"

MAKE="${MAKE:-make}"
BINUTILS_DIR_DEFAULT="${HOME}/.cache/binutils"
BINUTILS_DIR=${BINUTILS_DIR:-$BINUTILS_DIR_DEFAULT}
BINUTILS_SRC="${BINUTILS_DIR}/binutils-${BINUTILS_VERSION}"
BINUTILS_INSTALL_DIR="${BINUTILS_DIR}/${HOST_TRIPLET}_${FULL_TRIPLET}_${BINUTILS_VERSION}"

mkdir -p "${BINUTILS_DIR}"
cd "${BINUTILS_DIR}"
if [ ! -e  "binutils-${BINUTILS_VERSION}.tar.gz" ]; then
    curl -fSL "https://ftpmirror.gnu.org/binutils/binutils-${BINUTILS_VERSION}.tar.gz" -o "binutils-${BINUTILS_VERSION}.tar.gz"
fi
rm -rf "${BINUTILS_SRC}"
rm -rf "${BINUTILS_INSTALL_DIR}"
tar -xf "${BINUTILS_DIR}/binutils-${BINUTILS_VERSION}.tar.gz"
mkdir -p "${BINUTILS_INSTALL_DIR}"
cd "${BINUTILS_SRC}"

if [ "${HOST_ARCH}" = "${UNAME_M}" ]; then
    export CONFIGURE_HOST="" ;
else
    export CONFIGURE_HOST="--host='${HOST_TRIPLET}'" ;
fi

./configure \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix="${BINUTILS_INSTALL_DIR}" \
    --target="${FULL_TRIPLET}" \
    ${CONFIGURE_HOST} --disable-static \
    --disable-multilib \
    --disable-nls \
    --disable-werror

UNAME_S=$(uname -s)
case "${UNAME_S}" in
    Darwin*)
        $MAKE -j`sysctl -n hw.ncpu` ;;
    *Linux*)
        $MAKE -j`nproc` ;;
    *)
        $MAKE ;;
esac
$MAKE install && \
    rm -rf "${BINUTILS_INSTALL_DIR}/share" && \
    echo "[+] binutils installed to ${BINUTILS_INSTALL_DIR}"
