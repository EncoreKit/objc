import Foundation
import Encore

/// Wrapper for SDK configuration options.
///
/// Note: `unlockMode` is accepted but currently ignored — the public 1.4.x
/// `EncoreKit` surface only exposes `logLevel` via
/// `configure(apiKey:logLevel:)`. When EncoreKit promotes `UnlockMode` to a
/// public API, this class will forward the value. See `ARCHITECTURE.md`.
@objc(EncoreOptions)
public final class EncoreOptions: NSObject {
    @objc public var logLevel: EncoreLogLevel
    @objc public var unlockMode: EncoreUnlockMode

    @objc public override init() {
        self.logLevel = .none
        self.unlockMode = .optimistic
        super.init()
    }

    @objc public init(logLevel: EncoreLogLevel, unlockMode: EncoreUnlockMode) {
        self.logLevel = logLevel
        self.unlockMode = unlockMode
        super.init()
    }
}
