#!/bin/bash

PACKAGE_NAME=awesome
PACKAGE_SOURCE=.
PACKAGE_RESULT_NAME=awesome
SO_NAME=libawesome.so
ANDROID_PATH=../android
RUN_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
TARGET_PATH=$RUN_PATH/../target

if [ "$1" == "x86" ]; then
        echo "Build x86 only"
fi

if [ ! -n "$ANDROID_HOME" ]; then
        echo "Env ANDROID_HOME is empty"
        exit 1
fi

cd "$RUN_PATH"

NDK_HOME=$ANDROID_HOME/ndk/23.1.7779620
NDK_VERSION=`cat $NDK_HOME/source.properties | grep Pkg.Revision | awk '{print $3}' | awk -F. '{print $1}'`

echo "NDK_VERSION is $NDK_VERSION"


if [ $NDK_VERSION -lt 23 ];then
        echo "Requires Android ndk version >= 23"
        exit 1
else
        RUSTFLAGS+=" -L`pwd`/env/android"
fi

API=24

export ANDROID_NDK_ROOT=$NDK_HOME

OS=`uname | tr 'A-Z' 'a-z'`
if [ "$OS" != "darwin" -a  "$OS" != "linux" ]
then
        echo "not support for $OS"
        exit 1
fi

if [ "$OS" == "darwin" ];then
	TOOLCHAIN=$NDK_HOME/toolchains/llvm/prebuilt/darwin-x86_64
fi
if [ "$OS" == "linux" ];then
	TOOLCHAIN=$NDK_HOME/toolchains/llvm/prebuilt/linux-x86_64
fi

cargo uniffi-bindgen generate $RUN_PATH/awesome/src/lib.udl --config $RUN_PATH/awesome/uniffi.toml --language kotlin --out-dir $RUN_PATH/bindings/android || exit 1

if [ "$1" != "x86" ]; then
        rustup target add aarch64-linux-android armv7-linux-androideabi || exit 1
fi
rustup target add x86_64-linux-android || exit 1

if [ "$1" != "x86" ]; then
        PATH=$PATH:$TOOLCHAIN/bin \
	TARGET_CC=aarch64-linux-android$API-clang \
	CXX=aarch64-linux-android$API-clang++ \
	TARGET_AR=llvm-ar \
	CARGO_TARGET_AARCH64_LINUX_ANDROID_LINKER=aarch64-linux-android$API-clang \
	RUSTFLAGS=$RUSTFLAGS cargo build --target aarch64-linux-android -p $PACKAGE_NAME --release || exit 1

        PATH=$PATH:$TOOLCHAIN/bin \
	TARGET_CC=armv7a-linux-androideabi$API-clang \
	CXX=armv7a-linux-androideabi$API-clang++ \
	TARGET_AR=llvm-ar \
	CARGO_TARGET_ARMV7_LINUX_ANDROIDEABI_LINKER=armv7a-linux-androideabi$API-clang \
	RUSTFLAGS=$RUSTFLAGS cargo build --target armv7-linux-androideabi -p $PACKAGE_NAME --release || exit 1
fi

PATH=$PATH:$TOOLCHAIN/bin \
TARGET_CC=x86_64-linux-android$API-clang \
CXX=x86_64-linux-android$API-clang++ \
TARGET_AR=llvm-ar \
CARGO_TARGET_X86_64_LINUX_ANDROID_LINKER=x86_64-linux-android$API-clang \
RUSTFLAGS=$RUSTFLAGS cargo build --target x86_64-linux-android -p $PACKAGE_NAME --release || exit 1

type strip || exit 1
if [ "$1" != "x86" ]; then
        mkdir -p $ANDROID_PATH/src/main/jniLibs/arm64-v8a || exit 1
        cp $TARGET_PATH/aarch64-linux-android/release/$SO_NAME $ANDROID_PATH/src/main/jniLibs/arm64-v8a/$SO_NAME || exit 1
        strip $ANDROID_PATH/src/main/jniLibs/arm64-v8a/$SO_NAME
        mkdir -p $ANDROID_PATH/src/main/jniLibs/armeabi-v7a || exit 1
        cp $TARGET_PATH/armv7-linux-androideabi/release/$SO_NAME $ANDROID_PATH/src/main/jniLibs/armeabi-v7a/$SO_NAME || exit 1
        strip $ANDROID_PATH/src/main/jniLibs/armeabi-v7a/$SO_NAME
fi
mkdir -p $ANDROID_PATH/src/main/jniLibs/x86_64 || exit 1
cp $TARGET_PATH/x86_64-linux-android/release/$SO_NAME $ANDROID_PATH/src/main/jniLibs/x86_64/$SO_NAME || exit 1
strip $ANDROID_PATH/src/main/jniLibs/x86_64/$SO_NAME
mkdir -p $ANDROID_PATH/src/main/java/com/awesome || exit 1
cp $RUN_PATH/bindings/android/com/awesomerslibrary/Awesome.kt $ANDROID_PATH/src/main/java/com/awesomerslibrary/ || exit 1

# cp $ANDROID_PATH/$PACKAGE_RESULT_NAME/build/outputs/aar/$PACKAGE_RESULT_NAME-release.aar NDK/libs/$PACKAGE_RESULT_NAME.aar || exit 1
# mkdir -p example/android_example/app/libs
# cp NDK/libs/$PACKAGE_RESULT_NAME.aar example/android_example/app/libs/

echo "finish"