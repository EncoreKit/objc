# EncoreObjC

Objective-C overlay for the [Encore iOS SDK](https://github.com/EncoreKit/ios-sdk). Thin wrapper — zero business logic, only `@objc`-compatible types bridged over `EncoreKit`.

## Install

Add to your `Podfile`:

```ruby
pod 'EncoreObjC', '~> 0.1'
```

Then `pod install`. CocoaPods will transitively pull `EncoreKit` at the exact version this bridge was built against (see `config/sdk-versions.json`).

## Quick Start

```objc
#import <EncoreObjC/EncoreObjC.h>

// In AppDelegate didFinishLaunching:
EncoreOptions *opts = [EncoreOptions new];
opts.logLevel = EncoreLogLevelInfo;
opts.unlockMode = EncoreUnlockModeOptimistic;
[[EncoreClient shared] configureWithApiKey:@"pk_live_…" options:opts];

// After auth:
EncoreUserAttributes *attrs = [EncoreUserAttributes new];
attrs.email = currentUser.email;
[[EncoreClient shared] identifyWithUserId:currentUser.id attributes:attrs];

// Show a placement:
[[[EncoreClient shared] placement:@"paywall_abandon"]
    showWithCompletion:^(EncorePresentationResult *result, NSError *error) {
        if (error) { NSLog(@"[Encore] error: %@", error); return; }
        if (result.kind == EncorePresentationKindGranted) {
            // extend subscription, apply credit, etc.
        }
    }];
```

## Supported Surface

See [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) for the full Swift→Obj-C mapping. Swift-only APIs (`Combine.AnyPublisher`, `EncoreDelegate`) are intentionally not exposed — callers wanting those should use [EncoreKit](https://github.com/EncoreKit/ios-sdk) directly from Swift.

## Compatibility

| EncoreObjC | EncoreKit | iOS |
|:-----------|:----------|:----|
| `0.1.x`    | `1.4.42`  | 15+ |

## Development

See [`docs/runbooks/local-development.md`](docs/runbooks/local-development.md).

## License

MIT — see [LICENSE](LICENSE).
