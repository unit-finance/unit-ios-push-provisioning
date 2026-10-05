//
//  UNPushProvisioningAppLoader.swift
//  UnitPushProvisioning
//

import Foundation
import UIKit

/// Created by `UNPushProvisioningAppLoaderBridge` when the framework loads. Keep the `@objc` class name and selector stable.
@objc(UNPushProvisioningAppLoader)
final class UNPushProvisioningAppLoader: NSObject {
    // The bridge doesn't retain the loader, and the launch observer needs a live instance.
    private static var retained: UNPushProvisioningAppLoader?

    @objc func appLoaded() {
        UNPushProvisioningAppLoader.retained = self
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(appLaunched),
            name: UIApplication.didFinishLaunchingNotification,
            object: nil
        )
    }

    @objc private func appLaunched() {
        UNPushProvisioningRequirements.check()
    }
}
