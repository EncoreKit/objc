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
    case transportNetwork       = 100
    case transportPersistence   = 101
    case protocolHTTP           = 200
    case protocolAPI            = 201
    case protocolDecoding       = 202
    case integrationNotConfigured = 300
    case integrationInvalidApiKey = 301
    case integrationInvalidURL    = 302
    case domain                 = 400
}

extension EncoreError: @retroactive CustomNSError {
    public static var errorDomain: String { EncoreErrorInfo.domain }

    public var errorCode: Int {
        switch self {
        case .transport(.network):              return EncoreErrorCode.transportNetwork.rawValue
        case .transport(.persistence):          return EncoreErrorCode.transportPersistence.rawValue
        case .protocol(.http):                  return EncoreErrorCode.protocolHTTP.rawValue
        case .protocol(.api):                   return EncoreErrorCode.protocolAPI.rawValue
        case .protocol(.decoding):              return EncoreErrorCode.protocolDecoding.rawValue
        case .integration(.notConfigured):      return EncoreErrorCode.integrationNotConfigured.rawValue
        case .integration(.invalidApiKey):      return EncoreErrorCode.integrationInvalidApiKey.rawValue
        case .integration(.invalidURL):         return EncoreErrorCode.integrationInvalidURL.rawValue
        case .domain:                           return EncoreErrorCode.domain.rawValue
        @unknown default:                       return EncoreErrorCode.domain.rawValue
        }
    }

    public var errorUserInfo: [String: Any] {
        var info: [String: Any] = [
            NSLocalizedDescriptionKey: errorDescription ?? "Encore error"
        ]
        if let underlying = underlying {
            info[NSUnderlyingErrorKey] = underlying as NSError
        }
        switch self {
        case .protocol(.api(let status, let code, let message)):
            info[EncoreErrorInfo.statusKey]  = status
            info[EncoreErrorInfo.messageKey] = message
            if let code { info[EncoreErrorInfo.apiCodeKey] = code }
        case .protocol(.http(let status, let message)):
            info[EncoreErrorInfo.statusKey] = status
            if let message { info[EncoreErrorInfo.messageKey] = message }
        case .domain(let message):
            info[EncoreErrorInfo.messageKey] = message
        default:
            break
        }
        return info
    }
}
