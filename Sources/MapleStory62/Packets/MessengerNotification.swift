//
//  MessengerNotification.swift
//
//

import Foundation

public struct MessengerNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .messenger }

    public init() { }
}

