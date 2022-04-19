## Dependencies

### Rustup targets

```
rustup target add aarch64-apple-ios-sim
rustup target add aarch64-apple-ios
rustup target add x86_64-apple-ios
```

### Swift Bridge CLI

```
cargo install -f swift-bridge-cli --git https://github.com/chinedufn/swift-bridge
```

## Build

### Swift Package

* Run `./build-rust.sh` to build the framework.

## Use in Xcode Project

* Import it in the xcode project via the `add package` flow in xcode
