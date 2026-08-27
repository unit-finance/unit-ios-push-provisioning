//
//  UNPushProvisioningSDKManager.swift
//  UnitPushProvisioning
//
//  Created by Matan Rath on 30/06/2026.
//

import Foundation
import UIKit
import UnitCommon
#if canImport(VisaPushProvisioning)
@preconcurrency import VisaPushProvisioning
import VisaInAppModuleCore

// VPError ships as an NSObject/Encodable, not a Swift Error — make it throwable.
// @retroactive: we intentionally own this conformance (Visa doesn't declare it).
extension VPError: @retroactive Error {}
#endif

@objc(UNPushProvisioningSDKManager)
public final class UNPushProvisioningSDKManager: NSObject, UNPushProvisioningManagerProtocol {

    public override init() { super.init() }

#if canImport(VisaPushProvisioning)
    private var provisioningInterface: VisaPushProvisioningInterface?
    private var initializationContinuation: CheckedContinuation<String, Error>?
    private var supportedWalletsContinuation: CheckedContinuation<VPSupportedWalletResponse, Error>?
    private var cardProvisioningContinuation: CheckedContinuation<VPCardProvisioningResponse, Error>?
    private var unitEnvironment: UNEnvironment?

    @objc
    public func configure(environment: VisaInAppEnvironment, unitEnvironment: UNEnvironment, visaAppId: String) throws {
        let config = VisaInAppConfig(environment: environment, appId: visaAppId)
        try VisaInAppCore.configure(config: config)
        self.unitEnvironment = unitEnvironment
    }

    @objc
    public func walletStatus(cardId: String, customerToken: String) async throws -> VPProvisionStatus {
        let response = try await prepare(cardId: cardId, customerToken: customerToken)
        return response.wallets.first?.tokens.first?.provisionStatus ?? .NotAvailable
    }

    @objc
    public func startCardProvisioning(cardId: String, customerToken: String) async throws -> VPProvisionStatus {
        _ = try await prepare(cardId: cardId, customerToken: customerToken)
        guard let provisioningInterface else {
            throw UNPushProvisioningError.notConfigured
        }
        guard let viewController = await UIApplication.shared.topViewController() else {
            throw UNPushProvisioningError.noPresentingViewController
        }
        let response: VPCardProvisioningResponse = try await withCheckedThrowingContinuation { continuation in
            cardProvisioningContinuation = continuation
            let request = VPCardProvisioningRequest(walletCode: .ApplePayPushProvision, walletName: "apple")
            DispatchQueue.main.async {
                provisioningInterface.startCardProvisioning(request: request, initialView: viewController)
            }
        }
        return response.tokens.first?.provisionStatus ?? .NotAvailable
    }
#endif
}

#if canImport(VisaPushProvisioning)
private extension UNPushProvisioningSDKManager {
    /// Creates a fresh Visa push-provisioning interface and mints a signed nonce.
    func initialize() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            initializationContinuation = continuation
            provisioningInterface = VisaPushProvisioningInterfaceFactory.createPushProvisioningInterface(listener: self)
            provisioningInterface?.initialize()
        }
    }

    /// Asks the Visa SDK which wallets the encrypted payload is eligible for.
    func supportedWallets(for encryptedPayload: String) async throws -> VPSupportedWalletResponse {
        guard let provisioningInterface else { throw UNPushProvisioningError.notConfigured }
        return try await withCheckedThrowingContinuation { continuation in
            supportedWalletsContinuation = continuation
            provisioningInterface.getSupportedWallets(request: VPSupportedWalletRequest(encPayload: encryptedPayload))
        }
    }

    /// Runs the eligibility chain: initialize (nonce) → fetch payload → getSupportedWallets.
    func prepare(cardId: String, customerToken: String) async throws -> VPSupportedWalletResponse {
        guard let unitEnvironment else {
            throw UNPushProvisioningError.notConfigured
        }
        let signedNonce = try await initialize()
        let encryptedPayload = try await UNCardAPI(environment: unitEnvironment)
            .mobileWalletPayload(cardId: cardId, signedNonce: signedNonce, customerToken: customerToken)
        return try await supportedWallets(for: encryptedPayload)
    }
}
#endif

#if canImport(VisaPushProvisioning)
extension UNPushProvisioningSDKManager: VisaPushProvisioningListener {
    public func initializationSuccess(pushProvisioningInterface: VisaPushProvisioningInterface, response: VPInitResponse) {
        initializationContinuation?.resume(returning: response.signedNonce)
        initializationContinuation = nil
    }

    public func initializationFailure(pushProvisioningInterface: VisaPushProvisioningInterface, error: VPError) {
        initializationContinuation?.resume(throwing: error)
        initializationContinuation = nil
    }

    public func supportedWalletSuccess(pushProvisioningInterface: VisaPushProvisioningInterface, response: VPSupportedWalletResponse) {
        supportedWalletsContinuation?.resume(returning: response)
        supportedWalletsContinuation = nil
    }

    public func supportedWalletFailure(pushProvisioningInterface: VisaPushProvisioningInterface, error: VPError) {
        supportedWalletsContinuation?.resume(throwing: error)
        supportedWalletsContinuation = nil
    }

    public func cardProvisioningSuccess(pushProvisioningInterface: VisaPushProvisioningInterface, response: VPCardProvisioningResponse) {
        cardProvisioningContinuation?.resume(returning: response)
        cardProvisioningContinuation = nil
    }

    public func cardProvisioningFailure(pushProvisioningInterface: VisaPushProvisioningInterface, error: VPError) {
        cardProvisioningContinuation?.resume(throwing: error)
        cardProvisioningContinuation = nil
    }
}
#endif
