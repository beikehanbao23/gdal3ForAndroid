
#!/bin/sh

set -e

wget -q https://github.com/Kitware/CMake/releases/download/v3.22.3/cmake-3.22.3-linux-x86_64.tar.gz
tar xzf cmake-3.22.3-linux-x86_64.tar.gz
export PATH=$PWD/cmake-3.22.3-linux-x86_64/bin:$PATH

# Download Android NDK
wget -q https://dl.google.com/android/repository/android-ndk-r23b-linux.zip
unzip -q android-ndk-r23b-linux.zip

export ANDROID_NDK=$PWD/android-ndk-r23b
export NDK_TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64



# Build
PKG_CONFIG_LIBDIR=/tmp/install/lib/pkgconfig cmake .. \
 -DUSE_CCACHE=ON \
 -DCMAKE_INSTALL_PREFIX=/for_gdal/install \
 -DCMAKE_SYSTEM_NAME=Android \
 -DCMAKE_ANDROID_NDK=$ANDROID_NDK \
 -DCMAKE_ANDROID_ARCH_ABI=armeabi-v7a \
 -DCMAKE_SYSTEM_VERSION=24 \
 "-DCMAKE_PREFIX_PATH=/for_gdal/install;$NDK_TOOLCHAIN/sysroot/usr/" \
 -DGDAL_BUILD_OPTIONAL_DRIVERS=OFF \
  -DOGR_BUILD_OPTIONAL_DRIVERS=OFF \
 -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=NEVER \
 -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=NEVER \
 -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=NO \
 -DSFCGAL_CONFIG=disabled \
 -DHDF5_C_COMPILER_EXECUTABLE=disabled \
 -DHDF5_CXX_COMPILER_EXECUTABLE=disabled
make -j3
make install