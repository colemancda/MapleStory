//
//  UpdateStatsNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// Sent to a client to update one or more character stats.
/// Opcode: `updateStats` (0x1C)
public struct UpdateStatsNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .updateStats }

    /// Whether this update should show in the UI (usually true).
    public let announce: Bool

    /// Bitmask of which stats are included.
    public let stats: MapleStat

    // MARK: - Individual stat values (only those present in `stats` are read by client)

    public let skin: UInt8?
    public let face: UInt32?
    public let hair: UInt32?
    public let level: UInt8?
    public let job: Job?
    public let str: UInt16?
    public let dex: UInt16?
    public let int: UInt16?
    public let luk: UInt16?
    public let hp: UInt16?
    public let maxHp: UInt16?
    public let mp: UInt16?
    public let maxMp: UInt16?
    public let ap: UInt16?
    public let sp: UInt16?
    public let exp: UInt32?
    public let fame: UInt16?
    public let meso: UInt32?
}

// MARK: - Convenience Initializers

public extension UpdateStatsNotification {

    /// Update only HP (e.g. after taking damage).
    static func hp(_ hp: UInt16) -> UpdateStatsNotification {
        UpdateStatsNotification(
            announce: true,
            stats: .hp,
            skin: nil, face: nil, hair: nil, level: nil, job: nil,
            str: nil, dex: nil, int: nil, luk: nil,
            hp: hp, maxHp: nil, mp: nil, maxMp: nil,
            ap: nil, sp: nil, exp: nil, fame: nil, meso: nil
        )
    }

    /// Update HP and MP together.
    static func hpMp(_ hp: UInt16, _ mp: UInt16) -> UpdateStatsNotification {
        UpdateStatsNotification(
            announce: true,
            stats: [.hp, .mp],
            skin: nil, face: nil, hair: nil, level: nil, job: nil,
            str: nil, dex: nil, int: nil, luk: nil,
            hp: hp, maxHp: nil, mp: mp, maxMp: nil,
            ap: nil, sp: nil, exp: nil, fame: nil, meso: nil
        )
    }
}

// MARK: - Encoding

extension UpdateStatsNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        try container.encode(announce)
        try container.encode(UInt32(stats.rawValue))
        if stats.contains(.skin),    let v = skin    { try container.encode(v) }
        if stats.contains(.face),    let v = face    { try container.encode(v) }
        if stats.contains(.hair),    let v = hair    { try container.encode(v) }
        if stats.contains(.level),   let v = level   { try container.encode(v) }
        if stats.contains(.job),     let v = job     { try container.encode(v.rawValue) }
        if stats.contains(.str),     let v = str     { try container.encode(v) }
        if stats.contains(.dex),     let v = dex     { try container.encode(v) }
        if stats.contains(.int),     let v = int     { try container.encode(v) }
        if stats.contains(.luk),     let v = luk     { try container.encode(v) }
        if stats.contains(.hp),      let v = hp      { try container.encode(v) }
        if stats.contains(.maxHP),   let v = maxHp   { try container.encode(v) }
        if stats.contains(.mp),      let v = mp      { try container.encode(v) }
        if stats.contains(.maxMP),   let v = maxMp   { try container.encode(v) }
        if stats.contains(.availableAP), let v = ap  { try container.encode(v) }
        if stats.contains(.availableSP), let v = sp  { try container.encode(v) }
        if stats.contains(.exp),     let v = exp     { try container.encode(v) }
        if stats.contains(.fame),    let v = fame    { try container.encode(v) }
        if stats.contains(.meso),    let v = meso    { try container.encode(v) }
    }
}
