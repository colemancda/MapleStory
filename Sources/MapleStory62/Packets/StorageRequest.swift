//
//  StorageRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

public struct StorageRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .storage }

    /// 4 = withdraw, 5 = deposit, 7 = meso
    public let mode: UInt8

    public let inventoryType: UInt8?

    public let slot: UInt8?

    public let itemID: UInt32?

    public let quantity: Int16?

    public let meso: UInt32?
}

extension StorageRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.mode = try container.decode(UInt8.self)
        switch mode {
        case 4: // withdraw
            self.inventoryType = try container.decode(UInt8.self)
            self.slot = try container.decode(UInt8.self)
            self.itemID = nil; self.quantity = nil; self.meso = nil
        case 5: // deposit
            self.slot = UInt8(truncatingIfNeeded: try container.decode(Int16.self))
            self.itemID = try container.decode(UInt32.self)
            self.quantity = try container.decode(Int16.self)
            self.inventoryType = nil; self.meso = nil
        case 7: // meso
            self.meso = try container.decode(UInt32.self)
            self.inventoryType = nil; self.slot = nil; self.itemID = nil; self.quantity = nil
        default:
            self.inventoryType = nil; self.slot = nil; self.itemID = nil; self.quantity = nil; self.meso = nil
        }
    }
}
