//
//  UNPushProvisioningManagerProtocol.swift
//  UnitPushProvisioning
//
//  Created by Matan Rath on 30/06/2026.
//

import Foundation
#if canImport(VisaPushProvisioning)
import VisaPushProvisioning
#endif

public protocol UNPushProvisioningManagerProtocol {
    #if canImport(VisaPushProvisioning)
    func last4DigitsToVPCardInfo(_ last4Digits: String) -> VPIssuerCardInfo
    #endif
}

