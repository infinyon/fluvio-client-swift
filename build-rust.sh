#!/bin/sh

set -xe

CARGO_PROFILE="${CARGO_PROFILE:-dev}"
THISDIR=$(dirname $0)
cd $THISDIR
export RUST_LOG=debug
export SDKROOT=$(xcrun -sdk macosx --show-sdk-path)

export SWIFT_BRIDGE_OUT_DIR="$(pwd)/generated"

mkdir -p $SWIFT_BRIDGE_OUT_DIR

# Build the project for the desired platforms:
# cargo build --target x86_64-apple-darwin --profile=$CARGO_PROFILE
# cargo build --target aarch64-apple-darwin --profile=$CARGO_PROFILE
cargo build --target aarch64-apple-ios-sim --profile=$CARGO_PROFILE
cargo build --target aarch64-apple-ios --profile=$CARGO_PROFILE
cargo build --target x86_64-apple-ios --profile=$CARGO_PROFILE

mkdir -p target/lipo-simulator
lipo target/aarch64-apple-ios-sim/$CARGO_PROFILE/libfluvio_client_swift.a target/x86_64-apple-ios/$CARGO_PROFILE/libfluvio_client_swift.a -create -output target/lipo-simulator/libfluvio_client_swift.a

# mkdir -p target/lipo-macos
# lipo target/aarch64-apple-darwin/$CARGO_PROFILE/libfluvio_client_swift.a target/x86_64-apple-darwin/$CARGO_PROFILE/libfluvio_client_swift.a -create -output target/lipo-macos/libfluvio_client_swift.a

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
  --ios target/aarch64-apple-ios/$CARGO_PROFILE/libfluvio_client_swift.a \
  --simulator target/lipo-simulator/libfluvio_client_swift.a \
  --name FluvioClientSwift

mv FluvioClientSwift/rust_framework.xcframework FluvioClientSwift/FluvioRust.xcframework
sed -i '' 's/rust_framework/FluvioRust/g' ./FluvioClientSwift/Package.swift
sed -i '' 's/RustXcframework/FluvioRust/g' ./FluvioClientSwift/Sources/FluvioClientSwift/*.swift
sed -i '' 's/RustXcframework/FluvioRust/g' ./FluvioClientSwift/FluvioRust.xcframework/*/Headers/module.modulemap
