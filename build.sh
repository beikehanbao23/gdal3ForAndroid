
#!/bin/sh

set -e

wget -q https://github.com/Kitware/CMake/releases/download/v3.22.3/cmake-3.22.3-linux-x86_64.tar.gz
tar xzf cmake-3.22.3-linux-x86_64.tar.gz
export PATH=$PWD/cmake-3.22.3-linux-x86_64/bin:$PATH

# Download Android NDK
wget -q https://dl.google.com/android/repository/android-ndk-r23b-linux.zip
unzip -q android-ndk-r23b-linux.zip

export PATH=$PWD/cmake-3.22.3-linux-x86_64/bin:$PATH
export ANDROID_NDK=$PWD/android-ndk-r23b
export NDK_TOOLCHAIN=$ANDROID_NDK/toolchains/llvm/prebuilt/linux-x86_64
export JAVA_HOME=/usr/lib/jvm/java-8-openjdk-amd64


# Build GDAL For Android
cmake .. \
 -DUSE_CCACHE=ON \
 -DCMAKE_INSTALL_PREFIX=/for_gdal/install \
 -DCMAKE_SYSTEM_NAME=Android \
 -DCMAKE_ANDROID_NDK=$ANDROID_NDK \
 -DCMAKE_ANDROID_ARCH_ABI=arm64-v8a \
 -DCMAKE_SYSTEM_VERSION=24 \
 "-DCMAKE_PREFIX_PATH=/tmp/installv7;$NDK_TOOLCHAIN/sysroot/usr/" \
 -DCMAKE_FIND_ROOT_PATH_MODE_INCLUDE=NEVER \
 -DCMAKE_FIND_ROOT_PATH_MODE_LIBRARY=NEVER \
 -DCMAKE_FIND_USE_CMAKE_SYSTEM_PATH=NO \
 -DSFCGAL_CONFIG=disabled \
 -DHDF5_C_COMPILER_EXECUTABLE=disabled \
 -DHDF5_CXX_COMPILER_EXECUTABLE=disabled \
 -DGDAL_USE_SPATIALITE=ON \
 -DBUILD_JAVA_BINDINGS=ON \
 -DJAVA_INCLUDE_PATH2=/usr/lib/jvm/java-11-openjdk-amd64/include/linux/ \
 -DJAVA_AWT_INCLUDE_PATH=/usr/lib/jvm/java-11-openjdk-amd64/include/

make -j3
make install