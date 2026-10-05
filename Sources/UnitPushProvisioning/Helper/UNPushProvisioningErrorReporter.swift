//
//  UNPushProvisioningErrorReporter.swift
//  UnitPushProvisioning
//

import Combine
import Foundation
import UnitCommon

final class UNPushProvisioningErrorReporter {
    static let shared = UNPushProvisioningErrorReporter()

    // Serial queue guarding callbacks and replayedErrors.
    private let queue = DispatchQueue(label: "co.unit.pushprovisioning.error-reporter")
    private var callbacks = [UNPushProvisioningErrorCallback]()
    private var replayedErrors = [UNPushProvisioningError]()
    private var cancellables = Set<AnyCancellable>()

    private init() {
        setupObservers()
    }

    func addCallback(_ callback: @escaping UNPushProvisioningErrorCallback) {
        queue.async {
            self.callbacks.append(callback)
            let errors = self.replayedErrors
            guard !errors.isEmpty else { return }
            DispatchQueue.main.async {
                errors.forEach { callback($0) }
            }
        }
    }

    /// - Parameter replay: also deliver the error to callbacks added later, e.g. for errors found at app launch.
    func report(_ error: UNPushProvisioningError, replay: Bool = false) {
        queue.async {
            if replay {
                self.replayedErrors.append(error)
            }
            let callbacks = self.callbacks
            DispatchQueue.main.async {
                callbacks.forEach { $0(error) }
            }
        }
    }
}

private extension UNPushProvisioningErrorReporter {
    func setupObservers() {
        UnitCommonSDK.errorPipe.errors
            .compactMap { $0 as? UNPushProvisioningError }
            .sink { [weak self] error in
                self?.report(error)
            }
            .store(in: &cancellables)
    }
}
