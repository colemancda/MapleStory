//
//  ReactorHitNotification.swift
//

import Foundation

/// Triggers a reactor hit animation for clients.
///
public struct ReactorHitNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .reactorHit }

    public let objectID: UInt32

    public let state: UInt8

    public let x: Int16

    public let y: Int16

    public let stance: UInt8

    public let unknown: UInt16

    public let frameDelay: UInt8
}
