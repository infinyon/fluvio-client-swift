# build-rust.sh

#!/bin/bash

set -e

THISDIR=$(dirname $0)
cd $THISDIR

export SWIFT_BRIDGE_OUT_DIR="$(pwd)/generated"
# Build the project for the desired platforms:
cargo build --target x86_64-apple-darwin
cargo build --target aarch64-apple-ios
cargo build --target x86_64-apple-ios

swift-bridge-cli create-package \
  --bridges-dir ./generated \
  --out-dir FluvioClientSwift \
  --ios       target/x86_64-apple-ios/debug/libfluvio_client_swift.a \
  --simulator target/aarch64-apple-ios/debug/libfluvio_client_swift.a \
  --macos     target/x86_64-apple-darwin/debug/libfluvio_client_swift.a \
  --name FluvioClientSwift
