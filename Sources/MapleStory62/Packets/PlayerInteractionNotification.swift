//
//  PlayerInteractionNotification.swift
//
//

import Foundation

public struct PlayerInteractionNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .playerInteraction }

    public init() { }
}

