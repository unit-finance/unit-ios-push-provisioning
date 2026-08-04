//
//  UNPushProvisioningSDKManager.swift
//  UnitPushProvisioning
//
//  Created by Matan Rath on 30/06/2026.
//

import Foundation
#if canImport(VisaPushProvisioning)
import VisaPushProvisioning
#endif

@objc(UNPushProvisioningSDKManager)
public final class UNPushProvisioningSDKManager: NSObject, UNPushProvisioningManagerProtocol {

    public override init() { super.init() }

#if canImport(VisaPushProvisioning)
    @objc(last4DigitsToVPCardInfo:)
    public func last4DigitsToVPCardInfo(_ last4Digits: String) -> VPIssuerCardInfo {
        let vpCardInfo = VPIssuerCardInfo(last4Digits: last4Digits)
        return vpCardInfo
    }
#endif
}
