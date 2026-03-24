//
//  MTSOperationNotification.swift
//
//

import Foundation

public struct MTSOperationNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .mtsOperation }

    public init() { }
}

