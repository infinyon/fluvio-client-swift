use std::path::PathBuf;
use std::collections::HashMap;
use swift_bridge_build::{CreatePackageConfig, ApplePlatform};

fn main() {
    let out_dir = PathBuf::from("./generated");

    let bridges = vec!["src/lib.rs"];
    for path in &bridges {
        println!("cargo:rerun-if-changed={}", path);
    }

    swift_bridge_build::parse_bridges(bridges)
        .write_all_concatenated(out_dir, env!("CARGO_PKG_NAME"));

    /*
    let lib_name = format!("lib_{}.a", env!("CARGO_PKG_NAME"));

    swift_bridge_build::create_package(CreatePackageConfig {
        bridge_dir: PathBuf::from("./generated"),
        paths: HashMap::from([
            (ApplePlatform::IOS, "target/x86_64-apple-ios/debug/libmy_rust_lib.a".into()),
            (ApplePlatform::Simulator, "target/aarch64-apple-ios/debug/libmy_rust_lib.a".into()),
            (ApplePlatform::MacOS, "target/x86_64-apple-darwin/debug/libmy_rust_lib.a".into()),
        ]),
        out_dir: PathBuf::from("FluvioClientSwift"),
        package_name: String::from("FluvioClientSwift")
    });
    */
}


