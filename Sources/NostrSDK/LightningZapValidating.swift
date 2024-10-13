//
//  LightningZapValidating.swift
//  NostrSDK
//
//  Created by Terry Yiu on 10/8/24.
//

import Foundation

struct LNURLPayResponse: Codable {
    let allowsNostr: Bool?
    let nostrPubkey: String?
    let callback: String?
    let minSendable: Int64?
    let maxSendable: Int64?
}

public protocol LNURLPayRequesting {}
public extension LNURLPayRequesting {
    internal func lnurlPayResponse(for url: URL, dataRequester: DataRequesting = URLSession.shared) async throws -> LNURLPayResponse {
        let (data, _) = try await dataRequester.data(from: url, delegate: nil)
        return try JSONDecoder().decode(LNURLPayResponse.self, from: data)
    }
}
