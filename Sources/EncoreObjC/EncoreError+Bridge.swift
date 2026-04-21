import Foundation
import Encore

/// Domain/userInfo constants for NSErrors bridged from `EncoreError`.
/// Obj-C access: `EncoreErrorInfo.domain`, `EncoreErrorInfo.statusKey`, etc.
@objc(EncoreErrorInfo)
public final class EncoreErrorInfo: NSObject {
    @objc public static let domain: String     = "com.encorekit.EncoreError"
    @objc public static let statusKey: String  = "EncoreErrorStatusKey"
    @objc public static let apiCodeKey: String = "EncoreErrorApiCodeKey"
    @objc public static let messageKey: String = "EncoreErrorMessageKey"
    private override init() { super.init() }
}

/// Numeric code surfaced on `NSError.code` for errors originating from EncoreKit.
@objc(EncoreErrorCode)
public enum EncoreErrorCode: Int {
    case transportNetwork         = 100
    case transportPersistence     = 101
    case protocolHTTP             = 200
    case protocolAPI              = 201
    case protocolDecoding         = 202
    case integrationNotConfigured = 300
    case integrationInvalidApiKey = 301
    case integrationInvalidURL    = 302
    case domain                   = 400
}

extension EncoreError {
    /// Manual NSError mapping. We do not conform to `CustomNSError` because
    /// the type is imported from EncoreKit (a separate module), and Swift's
    /// `_bridgeToObjectiveC()` for errors uses the conformance from the home
    /// module — any conformance declared here would not be picked up.
    internal var asNSError: NSError {
        let code: Int
        switch self {
        case .transport(.network):         code = EncoreErrorCode.transportNetwork.rawValue
        case .transport(.persistence):     code = EncoreErrorCode.transportPersistence.rawValue
        case .protocol(.http):             code = EncoreErrorCode.protocolHTTP.rawValue
        case .protocol(.api):              code = EncoreErrorCode.protocolAPI.rawValue
        case .protocol(.decoding):         code = EncoreErrorCode.protocolDecoding.rawValue
        case .integration(.notConfigured): code = EncoreErrorCode.integrationNotConfigured.rawValue
        case .integration(.invalidApiKey): code = EncoreErrorCode.integrationInvalidApiKey.rawValue
        case .integration(.invalidURL):    code = EncoreErrorCode.integrationInvalidURL.rawValue
        case .domain:                      code = EncoreErrorCode.domain.rawValue
        @unknown default:                  code = EncoreErrorCode.domain.rawValue
        }

        var userInfo: [String: Any] = [
            NSLocalizedDescriptionKey: errorDescription ?? "Encore error"
        ]
        if let underlying = underlying {
            userInfo[NSUnderlyingErrorKey] = underlying as NSError
        }
        switch self {
        case .protocol(.api(let status, let apiCode, let message)):
            userInfo[EncoreErrorInfo.statusKey]  = status
            userInfo[EncoreErrorInfo.messageKey] = message
            if let apiCode { userInfo[EncoreErrorInfo.apiCodeKey] = apiCode }
        case .protocol(.http(let status, let message)):
            userInfo[EncoreErrorInfo.statusKey] = status
            if let message { userInfo[EncoreErrorInfo.messageKey] = message }
        case .domain(let message):
            userInfo[EncoreErrorInfo.messageKey] = message
        default:
            break
        }

        return NSError(domain: EncoreErrorInfo.domain, code: code, userInfo: userInfo)
    }
}

/// Maps any thrown error to an NSError in our domain when possible,
/// otherwise bridges via Swift's default.
internal func bridgedNSError(_ error: Error) -> NSError {
    if let encoreError = error as? EncoreError {
        return encoreError.asNSError
    }
    return error as NSError
}
