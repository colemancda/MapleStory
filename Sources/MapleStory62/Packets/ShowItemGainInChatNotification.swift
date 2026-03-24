//
//  ShowItemGainInChatNotification.swift
//
//

import Foundation

public struct ShowItemGainInChatNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showItemGainInChat }

    public init() { }
}

