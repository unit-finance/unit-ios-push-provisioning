//
//  UNProvisionStatusCompletion.swift
//  UnitPushProvisioning
//

import Foundation
#if canImport(VisaPushProvisioning)
import VisaPushProvisioning

public typealias UNProvisionStatusCompletion = (Result<VPProvisionStatus, UNPushProvisioningError>) -> Void
#endif
