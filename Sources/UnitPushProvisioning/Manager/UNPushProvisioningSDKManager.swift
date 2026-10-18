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

// @retroactive: Visa ships VPError without Swift's Error conformance.
extension VPError: @retroactive Error {}
#endif

/// The components SDK doesn't link this framework — it finds this class via `NSClassFromString`
/// and calls the `@objc` methods below by selector string. Renaming a method, changing a
/// parameter, or altering the `@objc` class name won't fail any build; it silently degrades to
/// "unavailable" at runtime in the components integration. Keep the class name and selectors stable.
@objc(UNPushProvisioningSDKManager)
final class UNPushProvisioningSDKManager: NSObject, UNPushProvisioningManagerProtocol {
    @objc static let shared = UNPushProvisioningSDKManager()

    private let errorReporter = UNPushProvisioningErrorReporter.shared
    private let customerTokenStore: UNCustomerTokenStoring

    init(sharedServices: UNCommonSharedServicesProviding = UNCommonSharedServicesProvider.shared) {
        customerTokenStore = sharedServices.customerTokenStore()
        super.init()
    }

    var customerToken: String? {
        get { customerTokenStore.customerToken }
        set { customerTokenStore.customerToken = newValue }
    }

    func addErrorCallback(_ callback: @escaping UNPushProvisioningErrorCallback) {
        errorReporter.addCallback(callback)
    }

#if canImport(VisaPushProvisioning)
    private var provisioningInterface: VisaPushProvisioningInterface?
    private var initializationContinuation: CheckedContinuation<String, Error>?
    private var supportedWalletsContinuation: CheckedContinuation<VPSupportedWalletResponse, Error>?
    private var cardProvisioningContinuation: CheckedContinuation<VPCardProvisioningResponse, Error>?
    private var environment: UNEnvironment?

    @objc
    func configure(environment: UNEnvironment, visaAppId: String) throws {
        do {
            let visaEnvironment: VisaInAppEnvironment = environment == .production ? .Production : .Sandbox
            let config = VisaInAppConfig(environment: visaEnvironment, appId: visaAppId)
            try VisaInAppCore.configure(config: config)
            self.environment = environment
        } catch {
            throw UNPushProvisioningError(operation: .configure, error: error)
        }
    }

    @objc
    func walletStatus(cardId: String) async throws -> VPProvisionStatus {
        do {
            let response = try await prepare(cardId: cardId, operation: .walletStatus)
            let applePayWallet = response.wallets.first { $0.code == .ApplePayPushProvision }
            let currentDeviceToken = applePayWallet?.tokens.first { $0.deviceType == .CurrentDevice }
            return currentDeviceToken?.walletStatus ?? .NotAvailable
        } catch {
            throw UNPushProvisioningError(operation: .walletStatus, error: error)
        }
    }

    @objc
    func startCardProvisioning(cardId: String) async throws -> VPProvisionStatus {
        do {
            _ = try await prepare(cardId: cardId, operation: .startCardProvisioning)
            guard let provisioningInterface else {
                throw UNPushProvisioningError(operation: .startCardProvisioning, reason: .notConfigured)
            }
            guard let viewController = await UIApplication.shared.topViewController() else {
                throw UNPushProvisioningError(operation: .startCardProvisioning, reason: .noPresentingViewController)
            }
            let response: VPCardProvisioningResponse = try await withCheckedThrowingContinuation { continuation in
                cardProvisioningContinuation = continuation
                let request = VPCardProvisioningRequest(walletCode: .ApplePayPushProvision, walletName: "apple")
                DispatchQueue.main.async {
                    provisioningInterface.startCardProvisioning(request: request, initialView: viewController)
                }
            }
            let currentDeviceToken = response.tokens.first { $0.deviceType == .CurrentDevice }
            return currentDeviceToken?.walletStatus ?? .NotAvailable
        } catch {
            throw UNPushProvisioningError(operation: .startCardProvisioning, error: error)
        }
    }

    // MARK: completion-handler variants

    func configure(environment: UNEnvironment, visaAppId: String, completion: @escaping UNPushProvisioningCompletion) {
        do {
            try configure(environment: environment, visaAppId: visaAppId)
            completion(.success(()))
        } catch {
            completion(.failure(UNPushProvisioningError(operation: .configure, error: error)))
        }
    }

    func walletStatus(cardId: String, completion: @escaping UNPushProvisioningStatusCompletion) {
        Task { @MainActor in
            do {
                let status = try await walletStatus(cardId: cardId)
                completion(.success(status))
            } catch {
                completion(.failure(UNPushProvisioningError(operation: .walletStatus, error: error)))
            }
        }
    }

    func startCardProvisioning(cardId: String, completion: @escaping UNPushProvisioningStatusCompletion) {
        Task { @MainActor in
            do {
                let status = try await startCardProvisioning(cardId: cardId)
                completion(.success(status))
            } catch {
                completion(.failure(UNPushProvisioningError(operation: .startCardProvisioning, error: error)))
            }
        }
    }
#endif
}

#if canImport(VisaPushProvisioning)
private extension UNPushProvisioningSDKManager {
    func initialize() async throws -> String {
        return try await withCheckedThrowingContinuation { continuation in
            initializationContinuation = continuation
            provisioningInterface = VisaPushProvisioningInterfaceFactory.createPushProvisioningInterface(listener: self)
            provisioningInterface?.initialize()
        }
    }

    func supportedWallets(
        for encryptedPayload: String,
        operation: UNPushProvisioningError.Operation
    ) async throws -> VPSupportedWalletResponse {
        guard let provisioningInterface else {
            throw UNPushProvisioningError(operation: operation, reason: .notConfigured)
        }
        return try await withCheckedThrowingContinuation { continuation in
            supportedWalletsContinuation = continuation
            provisioningInterface.getSupportedWallets(request: VPSupportedWalletRequest(encPayload: encryptedPayload))
        }
    }

    func prepare(cardId: String, operation: UNPushProvisioningError.Operation) async throws -> VPSupportedWalletResponse {
        guard let environment else {
            throw UNPushProvisioningError(operation: operation, reason: .notConfigured)
        }
        guard let customerToken, !customerToken.isEmpty else {
            throw UNPushProvisioningError(operation: operation, reason: .missingCustomerToken)
        }
        let signedNonce = try await initialize()
        let encryptedPayload = try await UNCardAPI(environment: environment)
            .mobileWalletPayload(cardId: cardId, signedNonce: signedNonce, customerToken: customerToken)
        return try await supportedWallets(for: encryptedPayload, operation: operation)
    }
}

#endif

#if canImport(VisaPushProvisioning)
private extension VPToken {
    // A token left mid verification is reported as provisioned, but it can't be used yet.
    var walletStatus: VPProvisionStatus {
        if tokenStatus == .RequiresActivation {
            return .ReadyToProvision
        }
        return provisionStatus
    }
}
#endif

#if canImport(VisaPushProvisioning)
extension UNPushProvisioningSDKManager: VisaPushProvisioningListener {
    func initializationSuccess(pushProvisioningInterface: VisaPushProvisioningInterface, response: VPInitResponse) {
        initializationContinuation?.resume(returning: response.signedNonce)
        initializationContinuation = nil
    }

    func initializationFailure(pushProvisioningInterface: VisaPushProvisioningInterface, error: VPError) {
        initializationContinuation?.resume(throwing: error)
        initializationContinuation = nil
    }

    func supportedWalletSuccess(pushProvisioningInterface: VisaPushProvisioningInterface, response: VPSupportedWalletResponse) {
        supportedWalletsContinuation?.resume(returning: response)
        supportedWalletsContinuation = nil
    }

    func supportedWalletFailure(pushProvisioningInterface: VisaPushProvisioningInterface, error: VPError) {
        supportedWalletsContinuation?.resume(throwing: error)
        supportedWalletsContinuation = nil
    }

    func cardProvisioningSuccess(pushProvisioningInterface: VisaPushProvisioningInterface, response: VPCardProvisioningResponse) {
        cardProvisioningContinuation?.resume(returning: response)
        cardProvisioningContinuation = nil
    }

    func cardProvisioningFailure(pushProvisioningInterface: VisaPushProvisioningInterface, error: VPError) {
        cardProvisioningContinuation?.resume(throwing: error)
        cardProvisioningContinuation = nil
    }
}
#endif
