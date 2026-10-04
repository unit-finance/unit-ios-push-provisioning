//
//  UNVisaVersionCompatibility.swift
//  UnitPushProvisioning
//

import Foundation
#if canImport(VisaPushProvisioning)
import VisaPushProvisioning
import os

enum UNVisaVersionCompatibility {
    /// The Visa in-app SDK version this SDK was built and verified against.
    static let supportedVisaVersion = "5.6.0"

    /// The Visa SDK version the host app has embedded, read from the framework bundle at runtime.
    static var embeddedVisaVersion: String? {
        Bundle(for: VisaPushProvisioningInterfaceFactory.self)
            .infoDictionary?["CFBundleShortVersionString"] as? String
    }

    /// Whether the embedded Visa SDK agrees with the supported version on major.minor.
    static var isSupported: Bool {
        guard let embedded = embeddedVisaVersion else { return false }
        return majorMinor(embedded) == majorMinor(supportedVisaVersion)
    }

    static func warnIfUnsupported() {
        guard !isSupported else { return }
        let logger = Logger(subsystem: "co.unit.pushprovisioning", category: "compatibility")
        if let embedded = embeddedVisaVersion {
            logger.warning("Embedded Visa SDK \(embedded, privacy: .public) does not match the version this SDK supports (\(supportedVisaVersion, privacy: .public)). Push provisioning may behave unexpectedly.")
        } else {
            logger.warning("Could not read the embedded Visa SDK version; compatibility with the supported version (\(supportedVisaVersion, privacy: .public)) cannot be verified.")
        }
    }

    // major.minor only: patch differences are treated as compatible.
    private static func majorMinor(_ version: String) -> String {
        version.split(separator: ".").prefix(2).joined(separator: ".")
    }
}
#endif
