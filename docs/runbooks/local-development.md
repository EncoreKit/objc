# Local Development

The example app at `example/` is a pure-Objective-C iOS app that smoke-tests the bridge against the real `EncoreKit` SDK pulled from CocoaPods trunk.

## Quick Start

```bash
cd objc
make demo-ios
```

This single command:

1. Runs `pod install` in `example/` (resolves `EncoreObjC` from `:path => '../'` and transitively `EncoreKit` at the pinned version from `config/sdk-versions.json`)
2. Builds the example app for an iPhone 15 simulator in Debug
3. Prints instructions to open in Xcode

Then:

1. Open `example/EncoreObjCExample.xcworkspace` in Xcode
2. Select a simulator or device
3. Cmd+R to run

## Prerequisites

| Requirement | Version |
|:---|:---|
| Xcode | 15+ |
| CocoaPods | 1.15+ |
| iOS Simulator | iOS 15+ |

## How It's Wired Up

### Path-linked pod

`example/Podfile`:

```ruby
pod 'EncoreObjC', :path => '../'
```

Any change to `Sources/EncoreObjC/*.swift` is picked up on the next build — no republish needed. Under the hood, CocoaPods generates a development-pod Xcode target pointing at the bridge source files, and depends on `EncoreKit` at the pinned version (which *is* resolved from CocoaPods trunk).

### EncoreKit version pin

The pin lives in **`config/sdk-versions.json`** and is read by `EncoreObjC.podspec`:

```json
{ "ios": { "EncoreKit": "1.4.42" } }
```

It is an exact pin (no `~>`), per the monorepo convention. The `scripts/release/sync-native-sdk.sh` script (or its CI workflow counterpart) opens a PR when a newer EncoreKit is published to trunk.

### Generated Obj-C header

When Xcode builds `EncoreObjC`, it generates `EncoreObjC-Swift.h` containing every `@objc` symbol exposed by `Sources/EncoreObjC/*.swift`. Your Obj-C code imports this via the module import:

```objc
#import <EncoreObjC/EncoreObjC.h>
// or
@import EncoreObjC;
```

The `EncoreObjC.h` umbrella header is produced by CocoaPods' `DEFINES_MODULE = YES` and re-exports the Swift-generated header via the framework's modulemap.

To inspect what's being exposed:

```bash
find example/Pods/Target\ Support\ Files/EncoreObjC -name "*.h"
```

## Running Tests

```bash
make test
```

Runs `xcodebuild test` against the `EncoreObjCExampleTests` scheme. Three test files:

- `EncoreObjCBridgeTests.m` — surface presence + smoke
- `EncoreEnumTests.m` — NS_ENUM raw values stable
- `EncoreErrorBridgingTests.m` — `EncoreError` → `NSError` bridging

## Linting the Podspec

```bash
make lint
```

Runs `pod lib lint --allow-warnings`, which fetches `EncoreKit` from trunk and compiles the bridge in a temp workspace. This is the same gate CI runs.

## Clean Rebuild

```bash
make clean-example     # remove build dirs
make nuke              # also wipe Pods, Podfile.lock, workspace, DerivedData
```

## Editing the Bridge from Xcode vs Your Editor

- **Xcode (recommended)**: Open `example/EncoreObjCExample.xcworkspace`. The development pod target lets you edit `Sources/EncoreObjC/*.swift` with full autocomplete and jump-to-def.
- **External editor (VSCode, etc.)**: Open `objc/` directly. `Package.swift` gives SourceKit-LSP enough context to resolve `import Encore`. Run `swift package resolve` once if LSP complains.

## Troubleshooting

### `pod install` fails: "Unable to find a specification for EncoreKit"

Your local CocoaPods spec repo is stale:

```bash
cd example && pod install --repo-update
```

### Obj-C header missing a symbol you just added

CocoaPods caches Swift compile output aggressively. Touch the file, rebuild, or:

```bash
make nuke && make setup-example
```

### `xcodebuild` picks the wrong simulator

Override via env var:

```bash
DESTINATION='platform=iOS Simulator,name=iPhone 16 Pro' make demo-ios
```
