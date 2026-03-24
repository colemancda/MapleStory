//
//  CancelTvSmegaNotification.swift
//
//

import Foundation

public struct CancelTvSmegaNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .cancelTvSmega }

    public init() { }
}

extension CancelTvSmegaNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws { }
}

