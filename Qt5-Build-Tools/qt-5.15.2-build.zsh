#!/bin/zsh
# $1 is the Build Directory
# $2 is the install directory

if [[ "$1" == "" ]] ; then
  echo "2 Arguments required: Build Directory for Qt, Install Directory"
fi

if [[ "$2" == "" ]] ; then
  echo "2 Arguments required: Build Directory for Qt, Install Directory"
fi

BUILD_DIR=$1
echo "BUILD_DIR=$BUILD_DIR"
INSTALL_DIR=$2
echo "INSTALL_DIR=$INSTALL_DIR"
umask 022

CpuBrand=`sysctl -n machdep.cpu.brand_string | grep "Apple" | wc -l`
if [ ${CpuBrand} != 0 ];
then
  ARCH=arm64
else
  ARCH=x86_64
fi

echo "ARCH=$ARCH"


SCRIPT_SOURCE_DIR=${0:a:h}
echo "SCRIPT_SOURCE_DIR=$SCRIPT_SOURCE_DIR"

if [[ ! -d "$BUILD_DIR" ]]; then
  echo "BUILD_DIR DOES NOT EXIST: CREATING........"
  mkdir -p $BUILD_DIR
fi

cd "$BUILD_DIR"

if [[ -e $BUILD_DIR/qt5 ]]; then
  echo "#-----------------------------------------------------------------------------"
  echo "# Resetting existing qt5 repository"
  echo "#-----------------------------------------------------------------------------"

  cd qt5
  git reset --hard
else
  echo "#-----------------------------------------------------------------------------"
  echo "# Cloning Qt5 into $BUILD_DIR/qt"
  echo "#-----------------------------------------------------------------------------"

  git clone git://code.qt.io/qt/qt5.git || exit $?
  cd qt5
  git checkout 5.15 || exit $?
  perl init-repository --module-subset=qtbase,qtdeclarative,qtgraphicaleffects,qtquickcontrols2,qtsvg,qttools
fi


echo "#-----------------------------------------------------------------------------"
echo "# Building Qt5.... "
echo "#-----------------------------------------------------------------------------"

cd "$BUILD_DIR"

flavor=dynamic

export VERSION=5.15.2

case $flavor in
  static)
    flags="\
      -release \
      -optimize-size \
      -ltcg \
      -static \
      -no-feature-qml-debug \
      -no-feature-assistant \
      -no-feature-designer \
      -no-feature-distancefieldgenerator \
      -no-feature-kmap2qmap \
      -no-feature-linguist \
      -no-feature-makeqpf \
      -no-feature-pixeltool \
      -no-feature-qev \
      -no-feature-qtattributionsscanner \
      -no-feature-qtdiag \
      -no-feature-qtpaths \
      -no-feature-qtplugininfo \
      "
    ;;
  dynamic)
    flags="\
      -release \
      -optimize-size \
      -force-debug-info \
      "
    ;;
  *)
    echo "Usage: $0 [static|dynamic]" > /dev/stderr
    exit 1
esac

if [ -d "Qt$VERSION-$ARCH" ]; then
  echo "Already built. Wiping Qt$VERSION-$ARCH and rebuilding..."
  rm -rf "$BUILD_DIR/Qt$VERSION-$ARCH"
fi

pushd qt5/qtbase > /dev/null
git reset --hard
case $ARCH in
  arm64)
    patch -p1 < "$SCRIPT_SOURCE_DIR/tools/macos/qtbase-apple-silicon.patch" || exit $?
    ;;
esac
popd > /dev/null

mkdir "Qt$VERSION-$ARCH" || exit $?
pushd "Qt$VERSION-$ARCH" > /dev/null
../qt5/configure \
    -opensource -confirm-license \
    --prefix=$INSTALL_DIR/Qt$VERSION-$ARCH/$VERSION/clang_$ARCH \
    --docdir=$INSTALL_DIR/Qt$VERSION-$ARCH/Docs/Qt-$VERSION \
    -feature-relocatable \
    -release \
    -optimize-size \
    -no-sql-db2 -no-sql-ibase -no-sql-mysql -no-sql-oci -no-sql-odbc -no-sql-psql -no-sql-tds \
    -nomake examples \
    -nomake tests \
    -qt-zlib -qt-libpng -qt-libjpeg \
    -no-freetype -no-harfbuzz \
    -no-openssl -securetransport \
    -no-icu \
    -no-fontconfig \
    -no-dbus \
    || exit $?
make -j || exit $?
make install || exit $?
popd > /dev/null


