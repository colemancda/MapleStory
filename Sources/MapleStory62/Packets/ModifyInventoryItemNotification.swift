//
//  ModifyInventoryItemNotification.swift
//
//

import Foundation

public struct ModifyInventoryItemNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .modifyInventoryItem }

    public init() { }
}

