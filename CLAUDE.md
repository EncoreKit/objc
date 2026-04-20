# EncoreObjC — Objective-C Overlay SDK

Thin `@objc` overlay over [EncoreKit](https://github.com/EncoreKit/ios-sdk). Source pod on CocoaPods trunk. Zero business logic — every method is a translation shim.

## Non-Negotiables

- **No business logic.** If it has to compute something, it belongs in the Swift SDK, not here.
- **`EncoreKit` pin is exact.** Edit `config/sdk-versions.json` (no `~>` ranges in the podspec). Per mono-memory: exact pins for debuggability.
- **Every new `@objc` symbol gets a test** in `Tests/EncoreObjCTests/`.
- **Never bridge deprecated Swift APIs** (`EncoreDelegate`, builder's deprecated callbacks).
- **No xcodegen.** Example app's `.xcodeproj` is hand-written. Xcodegen is not Apple-maintained.
- **Makefile is thin.** All logic lives in `scripts/`; Makefile only invokes them.

## Structure

- `Sources/EncoreObjC/` — the bridge (Swift source compiled in consumer toolchain)
- `example/` — Obj-C iOS app consuming the bridge via `pod 'EncoreObjC', :path => '../'`
- `Tests/EncoreObjCTests/` — XCTest in Obj-C, runs inside example workspace
- `scripts/demo/`, `scripts/release/` — Makefile-invoked bash
- `docs/runbooks/` — `local-development.md`, `release.md`
- `config/sdk-versions.json` — single source of truth for EncoreKit pin

## Architecture

See `docs/ARCHITECTURE.md` for the overlay pattern rationale + Swift→Obj-C mapping table.

## Evolution

The `bump-native-sdk.yml` workflow auto-PRs when `EncoreKit` on trunk is newer. API additions come via the cross-SDK propagation agent (see root `CLAUDE.md` §8 — Cross-SDK Parity).
