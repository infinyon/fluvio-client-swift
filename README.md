## Dependencies

### Rustup targets

```
rustup target add aarch64-apple-ios-sim
rustup target add aarch64-apple-ios
rustup target add x86_64-apple-ios
```

### Swift Bridge CLI

```
cargo install swift-bridge-cli -f --version 0.1.32
```

## Build

### Swift Package

* Run `./build-rust.sh` to build the framework.

## Use in Xcode Project

* Import it in the xcode project via the `add package` flow in xcode
