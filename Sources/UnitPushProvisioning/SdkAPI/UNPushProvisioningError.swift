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
    case missingCustomerToken
    case noPresentingViewController
    case network(UNNetworkError)
    #if canImport(VisaPushProvisioning)
    case visa(VPError)
    #endif
    case visaSDKMissing
    // embedded maps each mismatching Visa framework to the version found ("unknown" if unreadable).
    case unsupportedVisaVersion(embedded: [String: String], supported: String)
    case missingProvisioningEntitlement
    case unknown(Error)
}

extension UNPushProvisioningError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Push provisioning is not configured — call configure(...) first."
        case .missingCustomerToken:
            return "No customer token is set — set customerToken first."
        case .noPresentingViewController:
            return "No view controller available to present the provisioning flow."
        case .network(let error):
            return "The Unit network request failed: \(error.localizedDescription)"
        #if canImport(VisaPushProvisioning)
        case .visa(let error):
            return "Visa push provisioning failed: \(error.description)"
        #endif
        case .visaSDKMissing:
            return "The Visa SDK is not linked — add the Visa frameworks to your app."
        case .unsupportedVisaVersion(let embedded, let supported):
            let found = embedded.sorted { $0.key < $1.key }.map { "\($0.key) \($0.value)" }.joined(separator: ", ")
            return "Embedded Visa SDK does not match the supported version \(supported): \(found)."
        case .missingProvisioningEntitlement:
            return "The app is missing the Apple Pay in-app provisioning entitlement."
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
        case .unsupportedVisaVersion:     return 5
        case .visaSDKMissing:             return 6
        case .missingProvisioningEntitlement: return 7
        case .missingCustomerToken:       return 8
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
        case .notConfigured, .missingCustomerToken, .noPresentingViewController, .visaSDKMissing, .unsupportedVisaVersion, .missingProvisioningEntitlement:
            return [:]
        }
    }
}
