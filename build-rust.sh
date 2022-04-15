#!/bin/bash

set -e

THISDIR=$(dirname $0)
cd $THISDIR
export RUST_LOG=debug
export SDKROOT=$(xcrun -sdk macosx --show-sdk-path)

export SWIFT_BRIDGE_OUT_DIR="$(pwd)/generated"
# Build the project for the desired platforms:
#cargo build --target x86_64-apple-darwin
#cargo build --target aarch64-apple-ios-sim
cargo build --target aarch64-apple-darwin
cargo build --target aarch64-apple-ios
cargo build --target x86_64-apple-ios

#for OS in iphoneos iphonesimulator macosx; do
#	xcrun -sdk $OS --show-sdk-path
#	xcrun -sdk $OS --show-sdk-version
#	xcrun -sdk $OS --show-sdk-build-version
#	xcrun -sdk $OS --show-sdk-platform-path
#	xcrun -sdk $OS --show-sdk-platform-version
#done

swift-bridge-cli create-package \
  --bridges-dir ./generated \
  --out-dir FluvioClientSwift \
  --ios       target/x86_64-apple-ios/debug/libfluvio_client_swift.a \
  --simulator target/aarch64-apple-ios/debug/libfluvio_client_swift.a \
  --macos     target/aarch64-apple-darwin/debug/libfluvio_client_swift.a \
  --name FluvioClientSwift
sed -i '' 's/rust_framework/RustXcframework/g' ./FluvioClientSwift/Package.swift
