import Foundation
import Encore

@objc(EncoreUserAttributes)
public final class EncoreUserAttributes: NSObject {
    @objc public var email: String?
    @objc public var firstName: String?
    @objc public var lastName: String?
    @objc public var phoneNumber: String?
    @objc public var postalCode: String?
    @objc public var city: String?
    @objc public var state: String?
    @objc public var countryCode: String?
    @objc public var latitude: String?
    @objc public var longitude: String?
    @objc public var dateOfBirth: String?
    @objc public var gender: String?
    @objc public var language: String?
    @objc public var subscriptionTier: String?
    @objc public var monthsSubscribed: String?
    @objc public var billingCycle: String?
    @objc public var lastPaymentAmount: String?
    @objc public var lastActiveDate: String?
    @objc public var totalSessions: String?

    /// Deprecated in the Swift SDK — prefer remote-config-driven iapProductId.
    /// Still read as a fallback by `OfferSheetViewModel.grantEntitlement()`, so
    /// it's useful for exercising the `onPurchaseRequest` flow during local
    /// demos when the placement's remote config doesn't supply one.
    @objc public var iapProductId: String?

    @objc public var custom: [String: String]

    @objc public override init() {
        self.custom = [:]
        super.init()
    }

    internal var swift: UserAttributes {
        UserAttributes(
            email: email,
            firstName: firstName,
            lastName: lastName,
            phoneNumber: phoneNumber,
            postalCode: postalCode,
            city: city,
            state: state,
            countryCode: countryCode,
            latitude: latitude,
            longitude: longitude,
            dateOfBirth: dateOfBirth,
            gender: gender,
            language: language,
            subscriptionTier: subscriptionTier,
            monthsSubscribed: monthsSubscribed,
            billingCycle: billingCycle,
            lastPaymentAmount: lastPaymentAmount,
            lastActiveDate: lastActiveDate,
            totalSessions: totalSessions,
            iapProductId: iapProductId,
            custom: custom
        )
    }
}
