#!/bin/bash

set -e

THISDIR=$(dirname $0)
cd $THISDIR
export RUST_LOG=debug
export SDKROOT=$(xcrun -sdk macosx --show-sdk-path)

export SWIFT_BRIDGE_OUT_DIR="$(pwd)/generated"

mkdir -p $SWIFT_BRIDGE_OUT_DIR

# Build the project for the desired platforms:
# cargo build --target x86_64-apple-darwin
cargo build --target aarch64-apple-darwin
cargo build --target aarch64-apple-ios-sim --release
cargo build --target aarch64-apple-ios --release
cargo build --target x86_64-apple-ios --release

#for OS in iphoneos iphonesimulator macosx; do
#	xcrun -sdk $OS --show-sdk-path
#	xcrun -sdk $OS --show-sdk-version
#	xcrun -sdk $OS --show-sdk-build-version
#	xcrun -sdk $OS --show-sdk-platform-path
#	xcrun -sdk $OS --show-sdk-platform-version
#done

rm -r FluvioClientSwift/RustXcframework.xcframework || true

lipo target/aarch64-apple-ios-sim/release/libfluvio_client_swift.a target/x86_64-apple-ios/release/libfluvio_client_swift.a -create -output target/libfluvio_client_swift_sim.a

swift-bridge-cli create-package \
  --bridges-dir ./generated \
  --out-dir FluvioClientSwift \
  --ios target/aarch64-apple-ios/release/libfluvio_client_swift.a \
  --simulator target/libfluvio_client_swift_sim.a \
  --name FluvioClientSwift
sed -i '' 's/rust_framework/RustXcframework/g' ./FluvioClientSwift/Package.swift

mv FluvioClientSwift/rust_framework.xcframework FluvioClientSwift/RustXcframework.xcframework