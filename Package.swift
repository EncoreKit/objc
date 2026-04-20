// swift-tools-version: 5.9
//
// Local SPM manifest — used for developer tooling (SourceKit-LSP, `swift build`).
// Distribution is CocoaPods — see `EncoreObjC.podspec`. Consumers do not install
// via SPM (Obj-C interop through SPM is awkward).
//
// The EncoreKit version is pinned in `config/sdk-versions.json`; this manifest
// mirrors that pin manually. When bumping the SDK, update both.
//
import PackageDescription

let package = Package(
    name: "EncoreObjC",
    platforms: [.iOS(.v15)],
    products: [
        .library(name: "EncoreObjC", targets: ["EncoreObjC"])
    ],
    dependencies: [
        .package(url: "https://github.com/EncoreKit/ios-sdk-binary", exact: "1.4.42")
    ],
    targets: [
        .target(
            name: "EncoreObjC",
            dependencies: [
                .product(name: "Encore", package: "ios-sdk-binary")
            ],
            path: "Sources/EncoreObjC"
        )
    ]
)
