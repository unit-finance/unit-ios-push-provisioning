//
//  UNPushProvisioningRequirements.swift
//  UnitPushProvisioning
//

import Foundation

/// Checks, at app launch, that the host app has what push provisioning needs. Findings are reported to the
/// error callbacks only, so apps that don't register one see nothing; none of them stops the SDK from being used.
enum UNPushProvisioningRequirements {
    /// The Visa in-app SDK version this SDK was built and verified against.
    static let supportedVisaVersion = "5.6.0"

    private static let visaFrameworks = [
        "VisaPushProvisioning",
        "VisaInAppModuleCore",
        "VisaFeatureModuleCore",
        "VisaAnalytics",
        "VisaMobileFoundation"
    ]

    private static let provisioningEntitlement = "com.apple.developer.payment-pass-provisioning"

    static func check() {
        #if canImport(VisaPushProvisioning)
        checkVisaVersions()
        #else
        report(.visaSDKMissing)
        #endif
        checkEntitlement()
    }
}

private extension UNPushProvisioningRequirements {
    static func report(_ reason: UNPushProvisioningError.Reason, details: String? = nil) {
        let error = UNPushProvisioningError(operation: .requirementsCheck, reason: reason, details: details)
        UNPushProvisioningErrorReporter.shared.report(error, replay: true)
    }

    static func checkVisaVersions() {
        var mismatched = [String: String]()
        for name in visaFrameworks {
            let version = embeddedVersion(ofFramework: name)
            if version.map(majorMinor) != majorMinor(supportedVisaVersion) {
                mismatched[name] = version ?? "unknown"
            }
        }
        guard !mismatched.isEmpty else { return }
        let found = mismatched.sorted { $0.key < $1.key }.map { "\($0.key) \($0.value)" }.joined(separator: ", ")
        report(.unsupportedVisaVersion, details: "supported \(supportedVisaVersion), embedded \(found)")
    }

    static func embeddedVersion(ofFramework name: String) -> String? {
        Bundle.allFrameworks
            .first { $0.bundleURL.lastPathComponent == "\(name).framework" }?
            .infoDictionary?["CFBundleShortVersionString"] as? String
    }

    // major.minor only: patch differences are treated as compatible.
    static func majorMinor(_ version: String) -> String {
        version.split(separator: ".").prefix(2).joined(separator: ".")
    }

    static func checkEntitlement() {
        guard let entitlements = UNAppEntitlements.current() else { return }
        if entitlements[provisioningEntitlement] as? Bool != true {
            report(.missingProvisioningEntitlement)
        }
    }
}
