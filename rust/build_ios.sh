#!/bin/bash
PACKAGE_NAME=awesome
PACKAGE_BIN_NAME=libawesome.a
IOS_PATH=../ios
ARCHS_IOS=(x86_64-apple-ios aarch64-apple-ios aarch64-apple-ios-sim)
RUN_PATH=$( cd "$(dirname "${BASH_SOURCE[0]}")" ; pwd -P )
TARGET_PATH=$RUN_PATH/../target
XCFRAMEWORK=$IOS_PATH/libawesome.xcframework
OS=`uname | tr 'A-Z' 'a-z'`
if [ "$OS" != "darwin" ]
then
        echo "not support for $OS"
fi

cd "$RUN_PATH"

for i in "${ARCHS_IOS[@]}";
do
  rustup target add "$i";
done

cargo uniffi-bindgen generate $RUN_PATH/awesome/src/lib.udl --config $RUN_PATH/awesome/uniffi.toml --language swift --out-dir $RUN_PATH/bindings/ios || exit 1


for i in "${ARCHS_IOS[@]}";
do
  cargo build --target "$i"  -p $PACKAGE_NAME --release || exit 1
done

mkdir -p $IOS_PATH
mkdir -p $TARGET_PATH/sim

type strip || exit 1
# Create separate build for Simulator, TODO: check the architecture for Intel macs
lipo -create $TARGET_PATH/aarch64-apple-ios-sim/release/$PACKAGE_BIN_NAME $TARGET_PATH/x86_64-apple-ios/release/$PACKAGE_BIN_NAME -output  $TARGET_PATH/sim/$PACKAGE_BIN_NAME || exit 1
# Create separate build for Device
lipo -create $TARGET_PATH/aarch64-apple-ios/release/$PACKAGE_BIN_NAME -output $TARGET_PATH/$PACKAGE_BIN_NAME || exit 1

# Cleanup old build
rm -rf $XCFRAMEWORK || exit 1

# Create xcframework
xcodebuild -create-xcframework -library $TARGET_PATH/$PACKAGE_BIN_NAME -headers $RUN_PATH/bindings/ios/awesomeFFI.h \
 -library $TARGET_PATH/sim/$PACKAGE_BIN_NAME -headers $RUN_PATH/bindings/ios/awesomeFFI.h \
 -output $XCFRAMEWORK || exit 1

mkdir -p $IOS_PATH/include
cp $RUN_PATH/bindings/ios/awesomeFFI.h $IOS_PATH/include/ || exit 1
cp $RUN_PATH/bindings/ios/awesomeFFI.modulemap $IOS_PATH/include/ || exit 1
cp $RUN_PATH/bindings/ios/awesome.swift $IOS_PATH/ || exit 1
cd $IOS_PATH/

# strip -S $PACKAGE_BIN_NAME || exit 1

cd -
