#!/bin/sh

set -xe

CARGO_PROFILE=${CARGO_PROFILE:-dev}
CARGO_PROFILE_DIR=$([ "$CARGO_PROFILE" == "dev" ] && echo "debug" || echo "$CARGO_PROFILE")
THISDIR=$(dirname $0)
cd $THISDIR
export RUST_LOG=debug
export SDKROOT=$(xcrun -sdk macosx --show-sdk-path)

export SWIFT_BRIDGE_OUT_DIR="$(pwd)/generated"

mkdir -p $SWIFT_BRIDGE_OUT_DIR

# Build the project for the desired platforms:
cargo build --target aarch64-apple-ios-sim --profile=$CARGO_PROFILE
cargo build --target aarch64-apple-ios --profile=$CARGO_PROFILE
cargo build --target x86_64-apple-ios --profile=$CARGO_PROFILE

mkdir -p target/lipo-simulator
lipo target/aarch64-apple-ios-sim/$CARGO_PROFILE_DIR/libfluvio_client_swift.a target/x86_64-apple-ios/$CARGO_PROFILE_DIR/libfluvio_client_swift.a -create -output target/lipo-simulator/libfluvio_client_swift.a

#cargo build --target x86_64-apple-darwin --profile=$CARGO_PROFILE
#cargo build --target aarch64-apple-darwin --profile=$CARGO_PROFILE
#mkdir -p target/lipo-macos
#lipo target/aarch64-apple-darwin/$CARGO_PROFILE_DIR/libfluvio_client_swift.a target/x86_64-apple-darwin/$CARGO_PROFILE_DIR/libfluvio_client_swift.a -create -output target/lipo-macos/libfluvio_client_swift.a

# for OS in iphoneos iphonesimulator macosx; do
# 	xcrun -sdk $OS --show-sdk-path
# 	xcrun -sdk $OS --show-sdk-version
# 	xcrun -sdk $OS --show-sdk-build-version
# 	xcrun -sdk $OS --show-sdk-platform-path
# 	xcrun -sdk $OS --show-sdk-platform-version
# done

rm -r FluvioClientSwift || true

swift-bridge-cli create-package \
  --bridges-dir ./generated \
  --out-dir FluvioClientSwift \
  --ios target/aarch64-apple-ios/$CARGO_PROFILE_DIR/libfluvio_client_swift.a \
  --simulator target/lipo-simulator/libfluvio_client_swift.a \
  --name FluvioClientSwift
  #--macos target/lipo-macos/libfluvio_client_swift.a \

mv FluvioClientSwift/RustXcframework.xcframework FluvioClientSwift/FluvioRust.xcframework
sed -i '' 's/RustXcframework/FluvioRust/g' ./FluvioClientSwift/Package.swift
sed -i '' 's/RustXcframework/FluvioRust/g' ./FluvioClientSwift/Sources/FluvioClientSwift/*.swift
sed -i '' 's/RustXcframework/FluvioRust/g' ./FluvioClientSwift/FluvioRust.xcframework/*/Headers/module.modulemap
