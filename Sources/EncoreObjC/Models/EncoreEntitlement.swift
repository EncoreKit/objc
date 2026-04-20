import Foundation
import Encore

@objc(EncoreEntitlement)
public final class EncoreEntitlement: NSObject {
    @objc public let kind: EncoreEntitlementKind
    @objc public let value: NSNumber?
    @objc public let unit: EncoreEntitlementUnit

    @objc public init(kind: EncoreEntitlementKind, value: NSNumber?, unit: EncoreEntitlementUnit) {
        self.kind = kind
        self.value = value
        self.unit = unit
        super.init()
    }

    @objc public class func freeTrial(value: NSNumber?, unit: EncoreEntitlementUnit) -> EncoreEntitlement {
        EncoreEntitlement(kind: .freeTrial, value: value, unit: unit)
    }

    @objc public class func discount(value: NSNumber?, unit: EncoreEntitlementUnit) -> EncoreEntitlement {
        EncoreEntitlement(kind: .discount, value: value, unit: unit)
    }

    @objc public class func credit(value: NSNumber?, unit: EncoreEntitlementUnit) -> EncoreEntitlement {
        EncoreEntitlement(kind: .credit, value: value, unit: unit)
    }

    internal init(_ swift: Entitlement) {
        switch swift {
        case .freeTrial(let v, let u):
            self.kind = .freeTrial
            self.value = v.map { NSNumber(value: $0) }
            self.unit = EncoreEntitlementUnit(u)
        case .discount(let v, let u):
            self.kind = .discount
            self.value = v.map { NSNumber(value: $0) }
            self.unit = EncoreEntitlementUnit(u)
        case .credit(let v, let u):
            self.kind = .credit
            self.value = v.map { NSNumber(value: $0) }
            self.unit = EncoreEntitlementUnit(u)
        @unknown default:
            self.kind = .freeTrial
            self.value = nil
            self.unit = .unspecified
        }
        super.init()
    }

    internal var swift: Entitlement {
        let v = value?.doubleValue
        let u = unit.swift
        switch kind {
        case .freeTrial: return .freeTrial(value: v, unit: u)
        case .discount:  return .discount(value: v, unit: u)
        case .credit:    return .credit(value: v, unit: u)
        }
    }
}
