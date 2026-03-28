//
//  DestroyHiredMerchantNotification.swift
//

import Foundation

/// Destroys a hired merchant from the map.
///
public struct DestroyHiredMerchantNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .destroyHiredMerchant }

    public let ownerID: UInt32
}
