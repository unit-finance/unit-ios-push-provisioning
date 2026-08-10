//
//  UNVPIssuerCardInfo+Visa.swift
//  UnitPushProvisioning
//
//  Created by Matan Rath on 16/07/2026.
//

import Foundation
import UnitCommon
#if canImport(VisaPushProvisioning)
import VisaPushProvisioning
#endif

#if canImport(VisaPushProvisioning)
public extension UNVPIssuerCardInfo {
    @objc(asVisaCardInfo)
    func asVisaCardInfo() -> VPIssuerCardInfo {
        return VPIssuerCardInfo(last4Digits: last4Digits)
    }
}
#endif

#if canImport(VisaPushProvisioning)
extension VPIssuerCardInfo {
    @objc(asUnitCardInfo)
    func asUnitCardInfo() -> UNVPIssuerCardInfo {
        return UNVPIssuerCardInfo(last4Digits: last4Digits)
    }
}
#endif
