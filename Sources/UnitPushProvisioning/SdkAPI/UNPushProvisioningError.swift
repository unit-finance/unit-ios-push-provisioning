//
//  UNPushProvisioningError.swift
//  UnitPushProvisioning
//

import Foundation

@objc public enum UNPushProvisioningError: Int, Error {
    case notConfigured
    case noPresentingViewController
}
