//
//  UNPushProvisioningStatusCompletion.swift
//  UnitPushProvisioning
//

import Foundation
#if canImport(VisaPushProvisioning)
import VisaPushProvisioning

public typealias UNPushProvisioningStatusCompletion = (Result<VPProvisionStatus, UNPushProvisioningError>) -> Void
#endif
