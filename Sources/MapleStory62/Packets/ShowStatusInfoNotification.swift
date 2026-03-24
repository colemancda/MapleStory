//
//  ShowStatusInfoNotification.swift
//
//

import Foundation

public struct ShowStatusInfoNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .showStatusInfo }

    public init() { }
}

