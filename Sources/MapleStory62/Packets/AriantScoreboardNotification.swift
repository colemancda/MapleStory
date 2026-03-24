//
//  AriantScoreboardNotification.swift
//
//

import Foundation

public struct AriantScoreboardNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .ariantScoreboard }

    public init() { }
}

extension AriantScoreboardNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws { }
}

