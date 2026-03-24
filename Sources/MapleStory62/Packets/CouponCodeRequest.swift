//
//  CouponCodeRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct CouponCodeRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .couponCode }

    public let code: String
}

extension CouponCodeRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        let _ = try container.decode(UInt16.self)
        self.code = try container.decode(String.self)
    }
}
