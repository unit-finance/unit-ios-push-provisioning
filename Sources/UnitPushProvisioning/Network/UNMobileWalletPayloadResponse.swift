//
//  UNMobileWalletPayloadResponse.swift
//  UnitPushProvisioning
//

import Foundation

struct UNMobileWalletPayloadResponse: Decodable {
    struct Attributes: Decodable {
        let payload: String
    }
    struct WalletData: Decodable {
        let attributes: Attributes
    }

    let data: WalletData
    var payload: String { data.attributes.payload }
}
