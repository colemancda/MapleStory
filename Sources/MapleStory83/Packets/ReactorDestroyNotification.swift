//
//  ReactorDestroyNotification.swift
//

import Foundation

/// Destroys a reactor on the map.
///
public struct ReactorDestroyNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .reactorDestroy }

    public let objectID: UInt32

    public let state: UInt8

    public let x: Int16

    public let y: Int16
}
