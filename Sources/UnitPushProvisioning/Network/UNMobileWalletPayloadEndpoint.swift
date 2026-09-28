//
//  UNMobileWalletPayloadEndpoint.swift
//  UnitPushProvisioning
//

import Foundation
import UnitCommon

struct UNMobileWalletPayloadEndpoint: UNEndpoint {
    let cardId: String
    let signedNonce: String
    let customerToken: String

    var method: UNHTTPMethod { .post }
    var path: String { "/cards/\(cardId)/mobile-wallet-payload" }
    var isSecured: Bool { true }

    var headers: [String: String]? {
        [
            "Content-Type": "application/vnd.api+json",
            "Authorization": "Bearer \(customerToken)"
        ]
    }

    var body: Data? {
        let request = RequestBody(data: .init(attributes: .init(signedNonce: signedNonce)))
        do {
            return try JSONEncoder().encode(request)
        } catch {
            assertionFailure("Failed to encode mobile-wallet-payload body: \(error)")
            return nil
        }
    }
}

private struct RequestBody: Encodable {
    struct Attributes: Encodable {
        let signedNonce: String
    }
    struct DataObject: Encodable {
        let attributes: Attributes
    }

    let data: DataObject
}
