Pod::Spec.new do |spec|
  spec.name         = "FluvioClientSwift"
  spec.version      = "0.0.2"
  spec.summary      = "FluvioClient for Swift"
  spec.description  = <<-DESC
    FluvioClient for Swift
    FluvioClient for Swift
    FluvioClient for Swift
  DESC
  spec.homepage     = "https://github.com/infinyon/fluvio-client-swift"
  spec.license      = { :type => "Apache License, Version 2.0", :file => "LICENSE" }
  spec.author       = "Fluvio Team <team@fluvio.io>"
  spec.platform     = :ios, "12.0"
  spec.source       = { :http => "https://github.com/nacardin/podtest/releases/download/0.0.1/FluvioClientSwift2.zip" }
  # spec.source       = { :http => "https://github.com/infinyon/fluvio-client-swift/releases/download/#{spec.version}/FluvioClientSwift.zip" }
  spec.source_files = "FluvioClientSwift/Sources/**/*.{swift}"
  spec.vendored_frameworks  = "FluvioClientSwift/RustXcframework.xcframework"
end
