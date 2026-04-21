require "json"

versions = JSON.parse(File.read(File.join(__dir__, "config/sdk-versions.json")))
encorekit_pin = versions["ios"]["EncoreKit"]

Pod::Spec.new do |s|
  s.name             = "EncoreObjC"
  s.version          = "0.0.0"
  s.summary          = "Objective-C overlay for the Encore iOS SDK."
  s.description      = <<~DESC
    Thin @objc wrapper over EncoreKit. Lets Objective-C apps consume the
    Encore SDK without pulling in Swift-only types (structs, associated-value
    enums, async/await, Combine). Distributed as a source pod — depends on
    EncoreKit at an exact pinned version.
  DESC
  s.homepage         = "https://github.com/EncoreKit/objc"
  s.license          = { :type => "MIT", :file => "LICENSE" }
  s.author           = { "Encore" => "support@encorekit.com" }
  s.source           = { :git => "https://github.com/EncoreKit/objc.git", :tag => "v#{s.version}" }

  s.platform         = :ios, "15.0"
  s.swift_version    = "5.9"

  s.source_files     = "Sources/EncoreObjC/**/*.swift"

  s.dependency "EncoreKit", encorekit_pin

  s.pod_target_xcconfig = {
    "DEFINES_MODULE"                  => "YES",
    "SWIFT_INSTALL_OBJC_HEADER"       => "YES",
    "CLANG_ENABLE_MODULES"            => "YES",
    "APPLICATION_EXTENSION_API_ONLY"  => "NO"
  }

  s.frameworks = "Foundation", "UIKit", "StoreKit"
end
