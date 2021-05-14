#!/bin/bash

# This script is meant to make it easy to rebuild Boost using the linux-fresh
# yuzu-emu container.
# Re-purposed for building with MinGW for Windows.

# Run this from within boost_[version] directory
# Downloaded source archive must come from https://www.boost.org/

THIS=$(readlink -e $0)
TARGET="mingw"
ARCH=`uname -m`
BASE_NAME=`readlink -e $(pwd) | sed 's/.*\///g'`
ARCHIVE_NAME=${BASE_NAME}-${TARGET}-${ARCH}.tar.xz
XZ=$(which xz)
if [ -n "$(which pixz)" ]; then
    XZ=$(which pixz)
fi


echo "using gcc : mingw : ${ARCH}-w64-mingw32-g++ ;" > user-config.jam

mkdir -p /tmp || true
bash ./bootstrap.sh --without-libraries=python
./b2 --user-config=user-config.jam \
     --build-dir=build \
     --prefix=$(pwd)/${BASE_NAME} \
     abi=ms \
     address-model=64 \
     binary-format=pe \
     debug-symbols=off \
     define=NDEBUG \
     inlining=full \
     optimization=speed \
     target-os=windows \
     toolset=gcc-mingw \
     variant=release \
     install

cp -v ${THIS} ${BASE_NAME}/

tar cv ${BASE_NAME} | ${XZ} -c > ${ARCHIVE_NAME}

if [ $# -eq 2 ]; then
    chown -R $1:$2 .
fi

if [ -e ${ARCHIVE_NAME} ]; then
    echo "Boost package can be found at $(readlink -e ${ARCHIVE_NAME})"
fi


