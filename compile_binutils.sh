#!/bin/bash

ARCH=$1
if [ -z "${ARCH}" ]; then
    echo "Error: Please pass the desired arch, i.e., i386, x86_64, aarch64"
    exit 1
fi
if [ "$ARCH" == *"-"* ]; then
  FULL_TRIPLET="${ARCH}"
else
  FULL_TRIPLET="${ARCH}-unknown-linux-gnu"
fi
echo "[+] build for ${FULL_TRIPLET}"

BINUTILS_VERSION="${2:-2.38}"
echo "[+] using binutils ${BINUTILS_VERSION}"

MAKE="${MAKE:-make}"

BINUTILS_DIR="${HOME}/.cache/binutils"
BINUTILS_SRC="${BINUTILS_DIR}/binutils-${BINUTILS_VERSION}"
BINUTILS_INSTALL_DIR="${BINUTILS_DIR}/${FULL_TRIPLET}-${BINUTILS_VERSION}"

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
./configure \
    --disable-debug \
    --disable-dependency-tracking \
    --prefix="${BINUTILS_INSTALL_DIR}" \
    --target="${FULL_TRIPLET}" \
    --disable-static \
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
$MAKE install && echo "[+] binutils installed to ${BINUTILS_INSTALL_DIR}"
