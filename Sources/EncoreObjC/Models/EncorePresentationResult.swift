import Foundation
import Encore

@objc(EncorePresentationResult)
public final class EncorePresentationResult: NSObject {
    @objc public let kind: EncorePresentationKind
    @objc public let entitlement: EncoreEntitlement?
    @objc public let reason: EncoreNotGrantedReason

    internal init(_ swift: PresentationResult) {
        switch swift {
        case .granted(let e):
            self.kind = .granted
            self.entitlement = EncoreEntitlement(e)
            self.reason = .none
        case .notGranted(let r):
            self.kind = .notGranted
            self.entitlement = nil
            self.reason = EncoreNotGrantedReason(r)
        @unknown default:
            self.kind = .notGranted
            self.entitlement = nil
            self.reason = .dismissed
        }
        super.init()
    }
}
