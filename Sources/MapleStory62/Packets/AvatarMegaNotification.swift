//
//  AvatarMegaNotification.swift
//
//

import Foundation

public struct AvatarMegaNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .avatarMega }

    public init() { }
}

