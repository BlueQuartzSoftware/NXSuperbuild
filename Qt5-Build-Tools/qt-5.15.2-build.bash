#!/usr/bin/env bash

SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &> /dev/null && pwd)
echo $SCRIPT_DIR;

umask 022

#------------------------------------------------------------------------------
# Be sure to put 'llvm-config' on the PATH so that it can be found
# Prebuilts can be downloaded from GitHub
# https://github.com/llvm/llvm-project/releases/
# note the versions being used to build. There are issues with some of the other
# LLVM+Clang versions actually working correctly.
# ARM: 15.0.4
# x86_64: 11.0.0
#------------------------------------------------------------------------------


#------------------------------------------------------------------------------
# Figure out if we are on x86 or arm64
#------------------------------------------------------------------------------
CpuBrand=`sysctl -n machdep.cpu.brand_string | grep "Apple" | wc -l`
if [ ${CpuBrand} != 0 ];
then
  ARCH=arm64
  INSTALL_ARCH=arm64
  export QMAKE_MACOSX_DEPLOYMENT_TARGET=11.0
  export LLVM_INSTALL=/opt/local/clang+llvm-15.0.4-arm64-apple-darwin21.0
else
  ARCH=x86_64
  INSTALL_ARCH=64
  export QMAKE_MACOSX_DEPLOYMENT_TARGET=10.15
  export LLVM_INSTALL=/opt/local/clang+llvm-11.0.0-x86_64-apple-darwin
fi

if [ ! -e $LLVM_INSTALL ];
then
  echo "LLVM install does not exist: $LLVM_INSTALL"
  exit;
fi

export PATH=$PATH:$LLVM_INSTALL/bin

# set -e
# set -x

export NX_SDK_DIR=/Users/Shared/NX_SDK

#------------------------------------------------------------------------------
# Set the version of Qt5 that we are going to build
#------------------------------------------------------------------------------
VERSION=5.15.7

#------------------------------------------------------------------------------
# Where are we building Qt5
#------------------------------------------------------------------------------

DEV_ROOT=$NX_SDK_DIR/superbuild/Qt-$VERSION
mkdir -p $DEV_ROOT
cd $DEV_ROOT

#------------------------------------------------------------------------------
# Clone the Qt5 Sources
#------------------------------------------------------------------------------
export Qt5_SOURCE_DIR=qt-$VERSION-src

if [ ! -d "$Qt5_SOURCE_DIR" ]; then
  git clone -b v$VERSION-lts-lgpl ssh://git@github.com/qt/qt5 $Qt5_SOURCE_DIR
  cd $Qt5_SOURCE_DIR
  git submodule update --init --recursive
  cd $DEV_ROOT
fi

#------------------------------------------------------------------------------
# Set the build type (release is the only thing tested...)
#------------------------------------------------------------------------------
BUILD_TYPE=release

#------------------------------------------------------------------------------
# Set the INSTALL_ROOT and create the subdirectories
#------------------------------------------------------------------------------
INSTALL_ROOT=$NX_SDK_DIR/Qt
INSTALL_PREFIX=$INSTALL_ROOT/$VERSION/clang_$INSTALL_ARCH
DOC_INSTALL_PREFIX=$INSTALL_ROOT/Docs/Qt-$VERSION
EXAMPLE_INSTALL_PREFIX=$INSTALL_ROOT/Examples/Qt-$VERSION

mkdir -p $INSTALL_ROOT
mkdir -p $DOC_INSTALL_PREFIX
mkdir -p $EXAMPLE_INSTALL_PREFIX

#------------------------------------------------------------------------------
# Patch sources for macOS 11 (Big Sur) and macOS 12 (Monterey) compile and ARM64
#------------------------------------------------------------------------------
pushd $Qt5_SOURCE_DIR/qtbase > /dev/null
git reset --hard
case $ARCH in
  arm64)
    patch -p1 < "$SCRIPT_DIR/qtbase_qiosurfacegraphicsbuffer.patch" || exit $?
    patch -p1 < "$SCRIPT_DIR/qtbase-apple-silicon.patch" || exit $?
    ;;
esac
popd > /dev/null

pushd $Qt5_SOURCE_DIR/qt3d > /dev/null
git reset --hard
case $ARCH in
  arm64)
    patch -p1 < "$SCRIPT_DIR/qt3d_miniz.patch" || exit $?
    ;;
esac
popd > /dev/null

#------------------------------------------------------------------------------
# REMOVE ANY EXISTING BUILD !!!!!!
#------------------------------------------------------------------------------
cd $DEV_ROOT
export Qt5_BUILD_DIR=qt-$VERSION-$ARCH-$BUILD_TYPE
rm -rf $Qt5_BUILD_DIR
mkdir $Qt5_BUILD_DIR

#------------------------------------------------------------------------------
# Configure the sources for building on our platform
#------------------------------------------------------------------------------
cd $Qt5_BUILD_DIR
$DEV_ROOT/$Qt5_SOURCE_DIR/configure \
  --prefix=$INSTALL_PREFIX \
  --docdir=$DOC_INSTALL_PREFIX \
  --examplesdir=$EXAMPLE_INSTALL_PREFIX \
  -platform macx-clang \
  -device-option QMAKE_APPLE_DEVICE_ARCHS=$ARCH \
  -device-option QMAKE_MACOSX_DEPLOYMENT_TARGET=$QMAKE_MACOSX_DEPLOYMENT_TARGET \
  -$BUILD_TYPE \
  -opensource -confirm-license \
  -gui \
  -widgets \
  -no-gif \
  -no-icu \
  -no-pch \
  -no-angle \
  -no-dbus \
  -no-sqlite \
  -no-harfbuzz \
  -skip multimedia \
  -skip qtcanvas3d \
  -skip qtcharts \
  -skip qtconnectivity \
  -skip qtgamepad \
  -skip qtlocation \
  -skip qtmultimedia \
  -skip qtnetworkauth \
  -skip qtpurchasing \
  -skip qtremoteobjects \
  -skip qtscript \
  -skip qtsensors \
  -skip qtserialbus \
  -skip qtserialport \
  -skip qtwebchannel \
  -skip qtwebengine \
  -skip qtwebsockets \
  -skip qtxmlpatterns \
  -skip qtquick3d \
  -skip qtquickcontrols \
  -skip qtquickcontrols2 \
  -skip qtquicktimeline \
  -skip qtdeclarative \
  -skip qt3d \
  -nomake examples \
  -nomake tests \
  -make tools

# Need to install the tools BEFORE generating the docs
make -j

echo "#############################################################################"
echo "make install"
echo "#############################################################################"
make install

# Generate the Docs and install them
echo "#############################################################################"
echo "make docs"
echo "#############################################################################"
make docs

echo "#############################################################################"
echo "make install_docs"
echo "#############################################################################"
make install_docs