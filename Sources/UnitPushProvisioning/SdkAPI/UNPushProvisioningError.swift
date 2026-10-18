//
//  UNPushProvisioningError.swift
//  UnitPushProvisioning
//

import Foundation

public struct UNPushProvisioningError: Error {
    public enum Operation: String {
        case configure
        case walletStatus
        case startCardProvisioning
        case requirementsCheck
    }

    public enum Reason: String {
        case notConfigured
        case missingCustomerToken
        case noPresentingViewController
        case networkFailed
        case visaFailed
        case visaSDKMissing
        case unsupportedVisaVersion
        case missingProvisioningEntitlement
        case internalError
    }

    /// The SDK call or launch check that failed.
    public let operation: Operation

    /// Why it failed. Match on this to handle errors programmatically.
    public let reason: Reason

    /// Specifics for logs and support, e.g. the HTTP status and response body. Not contractual.
    public let details: String?

    /// The original error, e.g. a `UNNetworkError`, `URLError` or Visa `VPError`.
    public let underlyingError: Error?

    init(operation: Operation, reason: Reason, details: String? = nil, underlyingError: Error? = nil) {
        self.operation = operation
        self.reason = reason
        self.details = details
        self.underlyingError = underlyingError
    }
}

extension UNPushProvisioningError.Reason: CustomStringConvertible {
    public var description: String {
        switch self {
        case .notConfigured:
            return "push provisioning is not configured, call configure(environment:visaAppId:) first"
        case .missingCustomerToken:
            return "no customer token is set, set customerToken first"
        case .noPresentingViewController:
            return "no view controller is available to present the provisioning flow"
        case .networkFailed:
            return "the Unit API request failed"
        case .visaFailed:
            return "the Visa SDK returned an error"
        case .visaSDKMissing:
            return "the Visa SDK is not linked, add the Visa frameworks to the app"
        case .unsupportedVisaVersion:
            return "the embedded Visa SDK version is not supported"
        case .missingProvisioningEntitlement:
            return "the app is missing the Apple Pay in-app provisioning entitlement"
        case .internalError:
            return "internal SDK error"
        }
    }
}

extension UNPushProvisioningError: CustomStringConvertible {
    public var description: String {
        var result = "Error in \(operation.rawValue): \(reason)"
        if let details {
            result += " (\(details))"
        }
        return result
    }
}

extension UNPushProvisioningError: LocalizedError {
    public var errorDescription: String? {
        return description
    }
}

extension UNPushProvisioningError: CustomNSError {
    public static let operationUserInfoKey = "UNPushProvisioningOperation"

    public static var errorDomain: String {
        return "co.unit.UnitPushProvisioning.error"
    }

    public var errorCode: Int {
        switch reason {
        case .notConfigured:
            return 0
        case .missingCustomerToken:
            return 1
        case .noPresentingViewController:
            return 2
        case .networkFailed:
            return 3
        case .visaFailed:
            return 4
        case .visaSDKMissing:
            return 5
        case .unsupportedVisaVersion:
            return 6
        case .missingProvisioningEntitlement:
            return 7
        case .internalError:
            return 8
        }
    }

    public var errorUserInfo: [String: Any] {
        var userInfo: [String: Any] = [Self.operationUserInfoKey: operation.rawValue]
        if let underlyingError {
            userInfo[NSUnderlyingErrorKey] = underlyingError as NSError
        }
        return userInfo
    }
}
