//
//  UNPushProvisioningUI.swift
//  UnitPushProvisioning
//

import Foundation

// @objc so the components SDK can reach it by selector (`getAddToWalletButtonOnTap:`).
@objc
public protocol UNPushProvisioningUI: NSObjectProtocol {
    @MainActor
    func getAddToWalletButton(onTap: (() -> Void)?) -> UNAddToWalletButton
}
