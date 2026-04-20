import Foundation
import Encore

@objc(EncorePurchaseRequest)
public final class EncorePurchaseRequest: NSObject {
    @objc public let productId: String
    @objc public let placementId: String?
    @objc public let promoOfferId: String?

    @objc public init(productId: String, placementId: String?, promoOfferId: String?) {
        self.productId = productId
        self.placementId = placementId
        self.promoOfferId = promoOfferId
        super.init()
    }

    internal init(_ swift: PurchaseRequest) {
        self.productId = swift.productId
        self.placementId = swift.placementId
        self.promoOfferId = swift.promoOfferId
        super.init()
    }
}
