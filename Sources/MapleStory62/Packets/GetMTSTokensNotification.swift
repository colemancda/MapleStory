//
//  GetMTSTokensNotification.swift
//
//

import Foundation

public struct GetMTSTokensNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .getMTSTokens }

    public init() { }
}

