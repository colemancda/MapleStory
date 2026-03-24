//
//  ConfirmShopTransactionNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Notifies client of successful shop transaction (buy/sell/recharge)
public struct ConfirmShopTransactionNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .confirmShopTransaction }

    /// Transaction type (0 = buy, 1 = sell, 2 = recharge)
    public let mode: UInt8

    /// Item slot affected
    public let slot: Int16

    /// Item ID
    public let itemID: UInt32

    /// Quantity
    public let quantity: Int16

    /// Create transaction confirmation
    public init(mode: UInt8, slot: Int16, itemID: UInt32, quantity: Int16) {
        self.mode = mode
        self.slot = slot
        self.itemID = itemID
        self.quantity = quantity
    }
}
