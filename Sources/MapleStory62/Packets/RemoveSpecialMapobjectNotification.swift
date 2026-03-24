//
//  RemoveSpecialMapobjectNotification.swift
//
//

import Foundation

public struct RemoveSpecialMapobjectNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .removeSpecialMapobject }

    public init() { }
}

