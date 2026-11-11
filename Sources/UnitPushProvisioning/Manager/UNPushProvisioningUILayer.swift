//
//  UNPushProvisioningUILayer.swift
//  UnitPushProvisioning
//

import Foundation

final class UNPushProvisioningUILayer: UNPushProvisioningUI {
    @MainActor
    func getAddToWalletButton(onTap: (() -> Void)?) -> UNAddToWalletButton {
        return UNAddToWalletButton(onTap: onTap)
    }
}
