//
//  UNPushProvisioningError.swift
//  UnitPushProvisioning
//

import Foundation

@objc public enum UNPushProvisioningError: Int, Error {
    case notConfigured
    case noPresentingViewController
}

extension UNPushProvisioningError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .notConfigured:
            return "Push provisioning is not configured — call configure(...) first."
        case .noPresentingViewController:
            return "No view controller available to present the provisioning flow."
        }
    }
}
