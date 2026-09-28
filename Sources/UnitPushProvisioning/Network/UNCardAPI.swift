//
//  UNCardAPI.swift
//  UnitPushProvisioning
//

import Foundation
import UnitCommon

struct UNCardAPI {
    private let client: UNHTTPClient

    init(environment: UNEnvironment) {
        self.client = UNHTTPClient(environment: environment)
    }

    func mobileWalletPayload(cardId: String, signedNonce: String, customerToken: String) async throws -> String {
        let endpoint = UNMobileWalletPayloadEndpoint(
            cardId: cardId,
            signedNonce: signedNonce,
            customerToken: customerToken
        )
        return try await client.send(endpoint, as: UNMobileWalletPayloadResponse.self).payload
    }
}
