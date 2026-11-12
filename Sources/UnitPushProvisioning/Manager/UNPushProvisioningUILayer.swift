//
//  UNPushProvisioningUILayer.swift
//  UnitPushProvisioning
//

import Foundation

final class UNPushProvisioningUILayer: NSObject, UNPushProvisioningUI {
    @MainActor
    func getAddToWalletButton(onTap: (() -> Void)?) -> UNAddToWalletButton {
        return UNAddToWalletButton(onTap: onTap)
    }
}
