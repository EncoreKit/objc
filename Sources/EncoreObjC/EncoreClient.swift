import Foundation
import Encore

/// Objective-C facade for `Encore.shared`. Obj-C class name: `EncoreClient`.
///
/// Usage in Obj-C:
/// ```objc
/// [[EncoreClient shared] configureWithApiKey:@"pk_live_…" options:nil];
/// [[EncoreClient shared] identifyWithUserId:@"u_1" attributes:nil];
/// [[[EncoreClient shared] placement:@"paywall"]
///     showWithCompletion:^(EncorePresentationResult *r, NSError *e) { ... }];
/// ```
@objc(EncoreClient)
public final class EncoreClient: NSObject {

    @objc public static let shared = EncoreClient()
    private override init() { super.init() }

    // MARK: - Configuration

    @objc public func configure(apiKey: String, options: EncoreOptions?) {
        let logLevel = options?.logLevel.swift ?? .none
        Encore.shared.configure(apiKey: apiKey, logLevel: logLevel)
    }

    // MARK: - Identity

    @objc public func identify(userId: String, attributes: EncoreUserAttributes?) {
        Encore.shared.identify(userId: userId, attributes: attributes?.swift)
    }

    @objc public func setUserAttributes(_ attributes: EncoreUserAttributes) {
        Encore.shared.setUserAttributes(attributes.swift)
    }

    @objc public func reset() {
        Encore.shared.reset()
    }

    // MARK: - Placements

    @objc public func placement(_ id: String?) -> EncorePlacementBuilder {
        EncorePlacementBuilder(Encore.shared.placement(id))
    }

    // MARK: - Entitlements

    /// Obj-C: `-isActive:scope:completion:`
    @objc public func isActive(_ entitlement: EncoreEntitlement,
                               scope: EncoreEntitlementScope) async -> Bool {
        await Encore.shared.isActive(entitlement.swift, in: scope.swift)
    }

    /// Obj-C: `-revokeEntitlementsWithCompletion:` (auto-generated via SE-0297).
    @objc public func revokeEntitlements() async throws {
        try await Encore.shared.revokeEntitlements()
    }

    // MARK: - Purchase Handler

    /// Registers a purchase handler.
    ///
    /// The Obj-C block receives the purchase request and a completion block.
    /// Call the completion with `nil` NSError on success, or a non-nil NSError
    /// on failure. Failure is surfaced to Encore as a thrown error, which
    /// triggers the SDK's failure path.
    ///
    /// ```objc
    /// [[EncoreClient shared] onPurchaseRequest:^(EncorePurchaseRequest *req,
    ///                                            void (^done)(NSError *)) {
    ///     // do the purchase, then:
    ///     done(nil);
    /// }];
    /// ```
    @objc public func onPurchaseRequest(
        _ handler: @escaping (EncorePurchaseRequest,
                              @escaping (NSError?) -> Void) -> Void
    ) {
        _ = Encore.shared.onPurchaseRequest { request in
            try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<Void, Error>) in
                let wrapper = EncorePurchaseRequest(request)
                handler(wrapper) { error in
                    if let error = error {
                        continuation.resume(throwing: error)
                    } else {
                        continuation.resume(returning: ())
                    }
                }
            }
        }
    }

    // MARK: - Passthrough

    @objc public func onPassthrough(_ handler: @escaping (String?) -> Void) {
        _ = Encore.shared.onPassthrough(handler)
    }
}
