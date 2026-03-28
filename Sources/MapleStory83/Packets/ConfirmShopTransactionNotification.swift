//
//  ConfirmShopTransactionNotification.swift
//

import Foundation

/// Confirms or rejects an NPC shop transaction.
///
/// code: 0=success, 1=not enough stock, 2=not enough mesos, 3=inventory full, 0xD=need more items
public struct ConfirmShopTransactionNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .confirmShopTransaction }

    public let code: UInt8
}
