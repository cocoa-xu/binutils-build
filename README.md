# binutils-build

This repository contains a script to build binutils for macOS. It is intended to use with pwntools.

## Setup

```bash
# change to the directory where you want to install binutils
INSTALL_DIR="${HOME}/.local"

BINUTILS_VERSION="2.42"
TARGET_ARCH=x86_64
MACOS_ARCH=$(uname -m)
TARBALL_NAME="${MACOS_ARCH}-apple-darwin_${TARGET_ARCH}-unknown-linux-gnu_${BINUTILS_VERSION}"
TARBALL_URL="https://github.com/cocoa-xu/binutils-build/releases/download/v${BINUTILS_VERSION}/${TARBALL_NAME}.tar.gz"
TARBALL_SHA256_URL="https://github.com/cocoa-xu/binutils-build/releases/download/v${BINUTILS_VERSION}/${TARBALL_NAME}.tar.gz.sha256"

curl -fSL -o "${TARBALL_NAME}.tar.gz" "${TARBALL_URL}" && \
curl -fSL -o "${TARBALL_NAME}.tar.gz.sha256" "${TARBALL_SHA256_URL}" && \
shasum -c "${TARBALL_NAME}.tar.gz.sha256" && \
mkdir -p "${INSTALL_DIR}" && \
tar -xf "${TARBALL_NAME}.tar.gz" -C "${INSTALL_DIR}" && \
echo "binutils targeting ${TARGET_ARCH}-unknown-linux-gnu installed to ${INSTALL_DIR}/${TARBALL_NAME}" && \
echo "Please add these paths to your PATH environment variable:" && \
echo "  ${INSTALL_DIR}/${TARBALL_NAME}/bin" && \
echo "  ${INSTALL_DIR}/${TARBALL_NAME}/${TARGET_ARCH}-unknown-linux-gnu/bin"
```
