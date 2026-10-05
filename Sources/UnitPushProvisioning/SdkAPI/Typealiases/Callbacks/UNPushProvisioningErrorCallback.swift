//
//  UNPushProvisioningErrorCallback.swift
//  UnitPushProvisioning
//

import Foundation

/// A push provisioning error not returned from a call you made. Register via `addErrorCallback(_:)`.
public typealias UNPushProvisioningErrorCallback = (UNPushProvisioningError) -> Void
