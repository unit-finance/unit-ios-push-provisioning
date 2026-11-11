//
//  UNPushProvisioningUI.swift
//  UnitPushProvisioning
//

import Foundation

public protocol UNPushProvisioningUI: AnyObject {
    @MainActor
    func getAddToWalletButton(onTap: (() -> Void)?) -> UNAddToWalletButton
}
