//
//  UNPushProvisioningManagerProtocol.swift
//  UnitPushProvisioning
//
//  Created by Matan Rath on 30/06/2026.
//

import Foundation
import UnitCommon
#if canImport(VisaPushProvisioning)
import VisaPushProvisioning
import VisaInAppModuleCore
#endif

public protocol UNPushProvisioningManagerProtocol {
    #if canImport(VisaPushProvisioning)
    // MARK: async / throws
    func configure(environment: VisaInAppEnvironment, unitEnvironment: UNEnvironment, visaAppId: String) throws

    func walletStatus(cardId: String, customerToken: String) async throws -> VPProvisionStatus

    func startCardProvisioning(cardId: String, customerToken: String) async throws -> VPProvisionStatus

    // MARK: completion-handler
    func configure(environment: VisaInAppEnvironment, unitEnvironment: UNEnvironment, visaAppId: String, completion: @escaping UNDefaultCompletion)

    func walletStatus(cardId: String, customerToken: String, completion: @escaping UNProvisionStatusCompletion)

    func startCardProvisioning(cardId: String, customerToken: String, completion: @escaping UNProvisionStatusCompletion)
    #endif
}

