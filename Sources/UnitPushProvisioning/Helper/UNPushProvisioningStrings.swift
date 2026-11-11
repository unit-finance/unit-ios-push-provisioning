//
//  UNPushProvisioningStrings.swift
//  UnitPushProvisioning
//

import Foundation
import UnitCommon

enum UNPushProvisioningStrings {
    static func string(forKey key: String) -> String {
        return UNLocalizedStrings.string(forKey: key, bundle: bundle)
    }
}

private extension UNPushProvisioningStrings {
    final class BundleToken {}

    static var bundle: Bundle {
        #if SWIFT_PACKAGE
        return .module
        #else
        return Bundle(for: BundleToken.self)
        #endif
    }
}
