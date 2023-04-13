
export PATH=$PWD/cmake-3.22.3-linux-x86_64/bin:$PATH
export ANDROID_NDK=$PWD/android-ndk-r23b
export NDK_TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64

ccache -M 1G
ccache -s

# build sqlite3
cd sqlite-autoconf-3370200
CC="ccache $NDK_TOOLCHAIN/bin/aarch64-linux-android24-clang" ./configure \
  --prefix=/tmp/v8 --host=aarch64-linux-android24
make -j3
make install
cd ..

# Build proj

cd proj-9.0.0
mkdir buildv8
cd buildv8
# See later comment in GDAL build section about MAKE_FIND_ROOT_PATH_MODE_INCLUDE, CMAKE_FIND_ROOT_PATH_MODE_LIBRARY
cmake .. \
  -DUSE_CCACHE=ON \
  -DENABLE_TIFF=OFF -DENABLE_CURL=OFF -DBUILD_APPS=OFF -DBUILD_TESTING=OFF \
  -DCMAKE_INSTALL_PREFIX=/tmp/v8 \
  -DCMAKE_SYSTEM_NAME=Android \
  -DCMAKE_ANDROID_NDK=$ANDROID_NDK \
  -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
  -DCMAKE_SYSTEM_VERSION=24 \
  "-DCMAKE_PREFIX_PATH=/tmp/v8;$NDK_TOOLCHAIN/sysroot/usr/" \
  -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=NEVER \
  -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=NEVER \
  -DEXE_SQLITE3=/usr/bin/sqlite3
make -j3
make install
cd ../..

cd ~/gdal-3.6.0

mkdir buildv8
cd buildv8

# PKG_CONFIG_LIBDIR, CMAKE_FIND_ROOT_PATH_MODE_INCLUDE, CMAKE_FIND_ROOT_PATH_MODE_LIBRARY, CMAKE_FIND_USE_CMAKE_SYSTEM_PATH
# are needed because we don't install dependencies (PROJ, SQLite3) in the NDK sysroot
# This is definitely not the most idiomatic way of proceeding...
PKG_CONFIG_LIBDIR=/tmp/v8/lib/pkgconfig cmake .. \
 -DUSE_CCACHE=ON \
 -DCMAKE_INSTALL_PREFIX=/tmp/v8 \
 -DCMAKE_SYSTEM_NAME=Android \
 -DCMAKE_ANDROID_NDK=$ANDROID_NDK \
 -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
 -DCMAKE_SYSTEM_VERSION=24 \
 "-DCMAKE_PREFIX_PATH=/tmp/v8;$NDK_TOOLCHAIN/sysroot/usr/" \
 -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=NEVER \
 -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=NEVER \
 -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=NO \
 -DSFCGAL_CONFIG=disabled \
 -DHDF5_C_COMPILER_EXECUTABLE=disabled \
 -DHDF5_CXX_COMPILER_EXECUTABLE=disabled \
 -DGDAL_USE_SPATIALITE=ON \
 -DBUILD_JAVA_BINDINGS=ON \
 -DGDAL_USE_ICONV=OFF \
 -DOGR_BUILD_OPTIONAL_DRIVERS=OFF \
 -DGDAL_BUILD_OPTIONAL_DRIVERS=OFF \
 -DJAVA_INCLUDE_PATH2=/usr/lib/jvm/java-11-openjdk-amd64/include/linux/ \
 -DJAVA_AWT_INCLUDE_PATH=/usr/lib/jvm/java-11-openjdk-amd64/include/
make -j3
make install
cd ..

ccache -s