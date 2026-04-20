# Release Runbook

EncoreObjC is distributed via CocoaPods trunk as the `EncoreObjC` pod. A release is driven by `scripts/release/publish-release.sh` (via `make release`).

## Prerequisites

| Requirement | Notes |
|:---|:---|
| `pod trunk` session | `pod trunk me` must succeed. The trunk session is registered as `ryan@encorekit.com` (same session that owns `EncoreKit`). |
| Clean `main` branch | No uncommitted changes, tracking `origin/main`. |

## Versioning

EncoreObjC has **its own semver**, independent of `EncoreKit`. The dependency is pinned via `config/sdk-versions.json` (exact pin, no `~>`). See `docs/ARCHITECTURE.md` for the evolution model.

Rule of thumb:

- **Patch**: bug fix in a shim, `EncoreKit` pin bump, doc change
- **Minor**: new `@objc` wrapper added (non-breaking surface addition)
- **Major**: renamed/removed `@objc` symbol, changed method signature, changed `EncoreErrorCode` raw values

## Running a Release

```bash
cd objc
make release
```

The script walks 9 steps interactively:

1. Verify clean `main` + trunk auth.
2. Detect latest `v*` tag → current version.
3. Prompt for new version (`patch`/`minor`/`major` shortcuts or explicit `X.Y.Z`).
4. Show commit log since last release.
5. Confirm new version + pinned `EncoreKit`.
6. Update `EncoreObjC.podspec` version.
7. `pod lib lint --allow-warnings` (compiles against pinned `EncoreKit`).
8. Commit, tag `vX.Y.Z`, push to `origin`.
9. `pod trunk push EncoreObjC.podspec --allow-warnings`.

Version history is browsable at `/tags` in the GitHub repo (no GitHub Releases objects are created — the pod is source-only, so tags alone suffice for CocoaPods resolution). A hand-maintained `CHANGELOG.md` can be added at the repo root if you want richer release notes.

## Post-Release Smoke Test

```ruby
# Fresh Podfile
platform :ios, '15.0'
target 'SmokeTest' do
  pod 'EncoreObjC', 'X.Y.Z'     # the version you just released
end
```

```bash
pod install --repo-update
open SmokeTest.xcworkspace
```

Build the workspace. `@import EncoreObjC;` should resolve and `[EncoreClient shared]` should be callable from any `.m` file.

## Rolling Back

CocoaPods trunk does not allow deleting versions — but you can deprecate:

```bash
pod trunk deprecate EncoreObjC X.Y.Z
```

Then release `X.Y.Z+1` with the fix and update `README.md`'s compatibility table.

## Automated Dependency Sync

`.github/workflows/bump-native-sdk.yml` runs weekly (and on manual dispatch). It:

1. Fetches the latest `EncoreKit` version from CocoaPods trunk.
2. Compares against `config/sdk-versions.json`.
3. If newer, updates `config/sdk-versions.json` + `Package.swift` and opens a PR bumping `EncoreObjC.podspec` by one patch level.

Reviewer only needs to confirm CI green. Merge → tagged release pipeline publishes the patch bump.

## Publishing Credentials on CI

`.github/workflows/release.yml` uses the `COCOAPODS_TRUNK_TOKEN` secret. Rotate if compromised:

1. `pod trunk register <email>` from a laptop to get a new session.
2. Copy `~/.netrc` entry for `trunk.cocoapods.org`.
3. Set the new token at **Settings → Secrets and variables → Actions → COCOAPODS_TRUNK_TOKEN**.

## First Release Pre-Flight

Before the first `0.1.0` push:

```bash
pod trunk info EncoreObjC
```

Should return *No pod with the specified name was found* — confirms the name is unclaimed. If it is already claimed by someone else, rename the pod (e.g., `EncoreKitObjC`) in `EncoreObjC.podspec` and update cross-references.
