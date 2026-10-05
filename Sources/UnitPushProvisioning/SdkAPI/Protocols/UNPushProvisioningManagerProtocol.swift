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
#endif

public protocol UNPushProvisioningManagerProtocol: AnyObject {
    /// The customer token used for Unit API calls. Shared with the other Unit SDKs: setting it here or there updates both.
    var customerToken: String? { get set }

    /// Reports errors that are not returned from a call you made, e.g. an unsupported Visa SDK version.
    func addErrorCallback(_ callback: @escaping UNPushProvisioningErrorCallback)

    #if canImport(VisaPushProvisioning)
    // MARK: async / throws
    func configure(environment: UNEnvironment, visaAppId: String) throws

    func walletStatus(cardId: String) async throws -> VPProvisionStatus

    func startCardProvisioning(cardId: String) async throws -> VPProvisionStatus

    // MARK: completion-handler
    func configure(environment: UNEnvironment, visaAppId: String, completion: @escaping UNDefaultCompletion)

    func walletStatus(cardId: String, completion: @escaping UNProvisionStatusCompletion)

    func startCardProvisioning(cardId: String, completion: @escaping UNProvisionStatusCompletion)
    #endif
}

