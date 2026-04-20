import Foundation
import Encore

@objc(EncoreLogLevel)
public enum EncoreLogLevel: Int {
    case none  = 0
    case error = 1
    case warn  = 2
    case info  = 3
    case debug = 4

    internal init(_ swift: Encore.LogLevel) {
        self = EncoreLogLevel(rawValue: swift.rawValue) ?? .none
    }
    internal var swift: Encore.LogLevel {
        Encore.LogLevel(rawValue: rawValue) ?? .none
    }
}

/// Reserved for when EncoreKit exposes `UnlockMode` publicly.
/// Currently parked — `EncoreOptions.unlockMode` is accepted but ignored
/// until the Swift SDK promotes the type to public surface.
@objc(EncoreUnlockMode)
public enum EncoreUnlockMode: Int {
    case optimistic = 0
    case strict     = 1
}

@objc(EncoreEntitlementScope)
public enum EncoreEntitlementScope: Int {
    case all      = 0
    case verified = 1

    internal init(_ swift: EntitlementScope) {
        self = (swift == .verified) ? .verified : .all
    }
    internal var swift: EntitlementScope {
        self == .verified ? .verified : .all
    }
}

@objc(EncoreEntitlementKind)
public enum EncoreEntitlementKind: Int {
    case freeTrial = 0
    case discount  = 1
    case credit    = 2
}

@objc(EncoreEntitlementUnit)
public enum EncoreEntitlementUnit: Int {
    case unspecified = 0
    case months      = 1
    case days        = 2
    case percent     = 3
    case dollars     = 4

    internal init(_ swift: EntitlementUnit?) {
        guard let swift else { self = .unspecified; return }
        switch swift {
        case .months:    self = .months
        case .days:      self = .days
        case .percent:   self = .percent
        case .dollars:   self = .dollars
        @unknown default: self = .unspecified
        }
    }
    internal var swift: EntitlementUnit? {
        switch self {
        case .unspecified: return nil
        case .months:      return .months
        case .days:        return .days
        case .percent:     return .percent
        case .dollars:     return .dollars
        }
    }
}

@objc(EncorePresentationKind)
public enum EncorePresentationKind: Int {
    case granted    = 0
    case notGranted = 1
}

@objc(EncoreNotGrantedReason)
public enum EncoreNotGrantedReason: Int {
    case none               = 0
    case userTappedClose    = 1
    case userSwipedDown     = 2
    case userTappedOutside  = 3
    case userCancelled      = 4
    case lastOfferDeclined  = 5
    case dismissed          = 6
    case noOffersAvailable  = 7
    case unsupportedOS      = 8
    case experimentControl  = 9

    internal init(_ swift: NotGrantedReason) {
        switch swift {
        case .userTappedClose:   self = .userTappedClose
        case .userSwipedDown:    self = .userSwipedDown
        case .userTappedOutside: self = .userTappedOutside
        case .userCancelled:     self = .userCancelled
        case .lastOfferDeclined: self = .lastOfferDeclined
        case .dismissed:         self = .dismissed
        case .noOffersAvailable: self = .noOffersAvailable
        case .unsupportedOS:     self = .unsupportedOS
        case .experimentControl: self = .experimentControl
        @unknown default:        self = .dismissed
        }
    }
}
