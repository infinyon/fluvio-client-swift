#!/bin/bash

set -e

THISDIR=$(dirname $0)
cd $THISDIR
export RUST_LOG=debug
export SDKROOT=$(xcrun -sdk macosx --show-sdk-path)

export SWIFT_BRIDGE_OUT_DIR="$(pwd)/generated"

mkdir -p $SWIFT_BRIDGE_OUT_DIR

# Build the project for the desired platforms:
# cargo build --target x86_64-apple-darwin --release
# cargo build --target aarch64-apple-darwin --release
cargo build --target aarch64-apple-ios-sim --release
cargo build --target aarch64-apple-ios --release
cargo build --target x86_64-apple-ios --release

mkdir -p target/lipo-simulator
lipo target/aarch64-apple-ios-sim/release/libfluvio_client_swift.a target/x86_64-apple-ios/release/libfluvio_client_swift.a -create -output target/lipo-simulator/libfluvio_client_swift.a

# mkdir -p target/lipo-macos
# lipo target/aarch64-apple-darwin/release/libfluvio_client_swift.a target/x86_64-apple-darwin/release/libfluvio_client_swift.a -create -output target/lipo-macos/libfluvio_client_swift.a

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
  --ios target/aarch64-apple-ios/release/libfluvio_client_swift.a \
  --simulator target/lipo-simulator/libfluvio_client_swift.a \
  --name FluvioClientSwift

mv FluvioClientSwift/rust_framework.xcframework FluvioClientSwift/FluvioRust.xcframework
sed -i '' 's/rust_framework/FluvioRust/g' ./FluvioClientSwift/Package.swift
sed -i '' 's/RustXcframework/FluvioRust/g' ./FluvioClientSwift/**/*{.swift, .modulemap}
