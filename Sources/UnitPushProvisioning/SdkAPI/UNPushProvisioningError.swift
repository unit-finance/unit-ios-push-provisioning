//
//  UNPushProvisioningError.swift
//  UnitPushProvisioning
//

import Foundation
import UnitCommon
#if canImport(VisaPushProvisioning)
import VisaPushProvisioning
#endif

public enum UNPushProvisioningError: Error {
    case notConfigured
    case noPresentingViewController
    case network(UNNetworkError)
    #if canImport(VisaPushProvisioning)
    case visa(VPError)
    #endif
    case unknown(Error)
}

extension UNPushProvisioningError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Push provisioning is not configured — call configure(...) first."
        case .noPresentingViewController:
            return "No view controller available to present the provisioning flow."
        case .network(let error):
            return "The Unit network request failed: \(error.localizedDescription)"
        #if canImport(VisaPushProvisioning)
        case .visa(let error):
            return "Visa push provisioning failed: \(error.description)"
        #endif
        case .unknown(let error):
            return error.localizedDescription
        }
    }
}

// Bridges to NSError with a stable domain + codes and the underlying error under
// NSUnderlyingErrorKey, so Objective-C callers get an inspectable error even though the enum can't be @objc.
extension UNPushProvisioningError: CustomNSError {
    public static var errorDomain: String { "co.unit.UnitPushProvisioning.error" }

    public var errorCode: Int {
        switch self {
        case .notConfigured:              return 0
        case .noPresentingViewController: return 1
        case .network:                    return 2
        #if canImport(VisaPushProvisioning)
        case .visa:                       return 3
        #endif
        case .unknown:                    return 4
        }
    }

    public var errorUserInfo: [String: Any] {
        switch self {
        case .network(let error):
            return [NSUnderlyingErrorKey: error as NSError]
        #if canImport(VisaPushProvisioning)
        case .visa(let error):
            return [NSUnderlyingErrorKey: (error as Error) as NSError]
        #endif
        case .unknown(let error):
            return [NSUnderlyingErrorKey: error as NSError]
        case .notConfigured, .noPresentingViewController:
            return [:]
        }
    }
}
