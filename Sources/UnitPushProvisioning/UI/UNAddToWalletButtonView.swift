//
//  UNAddToWalletButtonView.swift
//  UnitPushProvisioning
//

import SwiftUI

public struct UNAddToWalletButtonView: UIViewRepresentable {
    private let onTap: (() -> Void)?

    public init(onTap: (() -> Void)? = nil) {
        self.onTap = onTap
    }

    public func makeUIView(context: Context) -> UNAddToWalletButton {
        return UnitPushProvisioningSDK.manager.ui.getAddToWalletButton(onTap: onTap)
    }

    public func updateUIView(_ uiView: UNAddToWalletButton, context: Context) {
        uiView.onTap = onTap
    }
}
