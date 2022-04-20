Pod::Spec.new do |spec|
  spec.name         = "FluvioClientSwift"
  spec.version      = "0.0.1"
  spec.summary      = "Fluvio client for Swift"
  spec.description  = <<-DESC
    Fluvio client for Swift. Wraps Rust Fluvio client.
  DESC
  spec.homepage     = "https://github.com/infinyon/fluvio-client-swift"
  spec.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  spec.author       = "Fluvio Team <team@fluvio.io>"
  spec.platform     = :ios, "12.0"
  spec.source       = { :http => "https://github.com/infinyon/fluvio-client-swift/releases/download/v#{spec.version}/FluvioClientSwift.zip" }
  spec.source_files = "FluvioClientSwift/Sources/**/*.{swift}"
  spec.swift_versions = '4.0'
  spec.vendored_frameworks  = "FluvioClientSwift/FluvioRust.xcframework"
end
