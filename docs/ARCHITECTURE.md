# Architecture

EncoreObjC is a thin `@objc` overlay over the Swift [`EncoreKit`](https://github.com/EncoreKit/ios-sdk) SDK. It holds no business logic — every method is a type-translation shim between the Swift public surface and Objective-C idioms.

## Why an Overlay Module?

Three choices were on the table:

1. **Annotate `EncoreKit` in place** — add `@objc` / `NSObject` to the Swift SDK's public types. Rejected: forces `NSObject` inheritance on `Encore`, flattens `Entitlement`'s associated-value enum, cascades through `UserAttributes`/`Options` structs. Contaminates the canonical Swift API.
2. **Source generate from Swift** — parse `EncoreKit.swiftinterface` and emit bridges. Rejected: brittle for associated-value enums; maintenance cost exceeds what the bridge saves.
3. **Overlay module** — a separate pod that `import Encore` and exposes `@objc` wrappers. Same pattern as [PSPDFKit/Nutrient](https://www.nutrient.io/blog/first-class-swift-api-for-objective-c-frameworks/). **This is what we chose.**

Benefits:

- Swift SDK stays pure (no `NSObject` inheritance, no `@objc` constraint on public types).
- The overlay sees only the `public` surface — `internal import OpenAPIRuntime` (SE-0409) in `EncoreKit` already ensures no generated types can leak into our bridge, even accidentally.
- `async` / `async throws` methods get auto-generated completion-handler variants (SE-0297) — we don't hand-write those.
- Ships as a source pod — no XCFramework slicing, no binary target, compiles at consumer install time. The wrapper is <500 LOC of thin shims.

## Bridge Mapping

### Core Facade

| Obj-C (EncoreObjC) | Swift (EncoreKit) | Notes |
|:---|:---|:---|
| `EncoreClient` class | `Encore` class | `@objc(EncoreClient)` — avoids Swift/Obj-C name collision |
| `+[EncoreClient shared]` | `Encore.shared` | singleton |
| `-configureWithApiKey:options:` | `configure(apiKey:options:)` | `options:` is `EncoreOptions *` (may be `nil`) |
| `-identifyWithUserId:attributes:` | `identify(userId:attributes:)` | |
| `-setUserAttributes:` | `setUserAttributes(_:)` | |
| `-reset` | `reset()` | |
| `-placement:` | `placement(_:)` | returns `EncorePlacementBuilder *` |
| `-isActive:scope:completion:` | `isActive(_:in:) async -> Bool` | auto-bridged via SE-0297 |
| `-revokeEntitlementsWithCompletion:` | `revokeEntitlements() async throws` | NSError on failure |
| `-onPurchaseRequest:` | `onPurchaseRequest { _ in ... }` | block signals async result via completion arg |
| `-onPassthrough:` | `onPassthrough { _ in ... }` | |

### Value Types

| Obj-C class | Swift type | Bridging strategy |
|:---|:---|:---|
| `EncoreOptions` | `Encore.Options` (struct) | `@objc` class, `logLevel` + `unlockMode` NS_ENUMs |
| `EncoreUserAttributes` | `UserAttributes` (struct) | `@objc` class with nullable `NSString` properties + `custom: NSDictionary` |
| `EncorePurchaseRequest` | `PurchaseRequest` (struct) | `@objc` class, all-`NSString` |
| `EncoreEntitlement` | `Entitlement` (enum w/ associated values) | `@objc` class: `kind` NS_ENUM + nullable `NSNumber *value` + `unit` NS_ENUM |
| `EncorePresentationResult` | `PresentationResult` (enum w/ associated values) | `@objc` class: `kind` NS_ENUM + nullable `entitlement` + `reason` NS_ENUM |

### NS_ENUMs

| Obj-C | Swift |
|:---|:---|
| `EncoreLogLevel` | `Encore.LogLevel` (Int raw) |
| `EncoreUnlockMode` | `UnlockMode` (rebuilt as Int raw) |
| `EncoreEntitlementScope` | `EntitlementScope` (rebuilt as Int raw) |
| `EncoreEntitlementKind` | `Entitlement` cases flattened (`freeTrial`/`discount`/`credit`) |
| `EncoreEntitlementUnit` | `EntitlementUnit` + `.unspecified` sentinel for Swift `nil` |
| `EncorePresentationKind` | `PresentationResult` cases (`granted`/`notGranted`) |
| `EncoreNotGrantedReason` | `NotGrantedReason` (rebuilt as Int raw) with `.none` sentinel |

### Errors

`EncoreError` conforms to `CustomNSError`. The bridged `NSError` has:

- `domain` = `EncoreErrorInfo.domain` (`com.encorekit.EncoreError`)
- `code` = one of `EncoreErrorCode` raw values
- `userInfo[NSLocalizedDescriptionKey]` = human-readable message
- `userInfo[NSUnderlyingErrorKey]` = wrapped system error, when present
- `userInfo[EncoreErrorInfo.statusKey]` = HTTP status, when applicable (`api`/`http`)
- `userInfo[EncoreErrorInfo.apiCodeKey]` = API error code, when applicable (`api`)
- `userInfo[EncoreErrorInfo.messageKey]` = raw server/domain message, when applicable

Obj-C usage:

```objc
[[EncoreClient shared] revokeEntitlementsWithCompletion:^(NSError *error) {
    if ([error.domain isEqualToString:EncoreErrorInfo.domain]
        && error.code == EncoreErrorCodeIntegrationNotConfigured) {
        // call configureWithApiKey: first
    }
}];
```

## Not Bridged

These Swift APIs are intentionally **Swift-only**. Consumers needing them must use `EncoreKit` directly from Swift:

- `Encore.isActivePublisher(for:in:)` — returns `AnyPublisher<Bool, Never>` (Combine). Obj-C consumers poll `isActive:scope:completion:` or subscribe to their own state.
- `Encore.entitlementsDelegate` — deprecated.
- `PlacementBuilder.onLoadingStateChange`, `onGranted`, `onNotGranted` — deprecated builder callbacks.
- `Encore.onPurchaseComplete { StoreKit.Transaction, String in ... }` — `StoreKit.Transaction` is a Swift struct (iOS 15+ StoreKit 2). Could be surfaced as `id` (opaque) in a follow-up if needed.

## Forward-Compatible Placeholders

The bridge exposes a few symbols whose underlying Swift counterparts are **not yet public in the pinned `EncoreKit` binary**. They are kept so that Obj-C call sites written today don't have to change when the Swift SDK exposes them:

- `EncoreOptions.unlockMode` — `UnlockMode` is still internal in `EncoreKit 1.4.42`. The `unlockMode` property is accepted but currently ignored; only `logLevel` is forwarded. When `UnlockMode` becomes public, this class will forward the value (minor bump).
- `EncoreClient.onPurchaseRequest`'s completion signature takes only `NSError *` (no `BOOL`). The `Bool`-returning overload exists in the Swift dev source but is not in the 1.4.42 binary. When released, a minor-bump will add an `onPurchaseRequestWithResult:` variant alongside — the existing signature stays for compatibility.

## Evolution

See root `README.md` → Compatibility and [`docs/runbooks/release.md`](runbooks/release.md). Summary:

| `EncoreKit` change | Bridge response | Automation |
|:---|:---|:---|
| Patch/minor (no public API change) | Patch-bump EncoreObjC, bump pin | `bump-native-sdk.yml` weekly PR |
| New public Swift API | New `@objc` wrapper + test + row in this file | Cross-SDK propagation agent (see monorepo `CLAUDE.md` §8) |
| Breaking API change | Major-bump EncoreObjC, migration note | Parity spec drives the plan |

## File Structure

```
Sources/EncoreObjC/
├── EncoreClient.swift              # @objc(EncoreClient) singleton facade
├── EncorePlacementBuilder.swift    # wraps PlacementBuilderProtocol
├── EncoreError+Bridge.swift        # CustomNSError conformance
├── Enums.swift                     # NS_ENUM Int-raw mirrors
└── Models/
    ├── EncoreEntitlement.swift
    ├── EncorePresentationResult.swift
    ├── EncoreUserAttributes.swift
    ├── EncorePurchaseRequest.swift
    └── EncoreOptions.swift
```

No other Swift files are shipped. Internal helpers (`.swift` utilities, etc.) should live in the main Swift SDK, not here.
