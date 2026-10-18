//
//  UNPushProvisioningError+Mapping.swift
//  UnitPushProvisioning
//

import Foundation
import UnitCommon
#if canImport(VisaPushProvisioning)
import VisaInAppModuleCore
import VisaPushProvisioning
#endif

extension UNPushProvisioningError {
    init(operation: Operation, error: Error) {
        switch error {
        case let pushProvisioningError as UNPushProvisioningError:
            self = pushProvisioningError
        case let networkError as UNNetworkError:
            self.init(
                operation: operation,
                reason: .networkFailed,
                details: networkError.details,
                underlyingError: networkError
            )
        case let urlError as URLError:
            self.init(
                operation: operation,
                reason: .networkFailed,
                details: urlError.localizedDescription,
                underlyingError: urlError
            )
        #if canImport(VisaPushProvisioning)
        case let visaError as VPError:
            self.init(
                operation: operation,
                reason: .visaFailed,
                details: visaError.description,
                underlyingError: visaError
            )
        case let configError as VisaInAppConfigException:
            self.init(
                operation: operation,
                reason: .visaFailed,
                details: configError.message,
                underlyingError: configError
            )
        #endif
        default:
            self.init(
                operation: operation,
                reason: .internalError,
                details: error.localizedDescription,
                underlyingError: error
            )
        }
    }
}

private extension UNNetworkError {
    var details: String {
        switch self {
        case .http(let statusCode, let data):
            let body = data.flatMap { String(data: $0, encoding: .utf8) } ?? ""
            return "HTTP \(statusCode): \(body)"
        case .invalidResponse:
            return "invalid response"
        case .decoding(let error):
            return "decoding failed: \(error)"
        @unknown default:
            return "unknown"
        }
    }
}
