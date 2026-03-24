//
//  MoveLifeRequest.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Mob movement control packet sent by the controlling client.
public struct MoveLifeRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .moveLife }

    /// Monster map object ID
    public let objectID: UInt32

    /// Movement sequence ID
    public let moveID: UInt16

    /// Non-zero if the monster is using a skill this tick
    public let skillByte: UInt8

    /// Skill indicator byte (-1 = no aggro change)
    public let skill: UInt8

    public let skillID: UInt8

    public let skillLevel: UInt8

    public let skillParam: UInt8

    /// Starting position X
    public let startX: Int16

    /// Starting position Y
    public let startY: Int16

    /// Decoded movement commands to relay to other clients.
    public let movements: [Movement]
}

extension MoveLifeRequest: MapleStoryDecodable {

    public init(from container: MapleStoryDecodingContainer) throws {
        self.objectID = try container.decode(UInt32.self)
        self.moveID = try container.decode(UInt16.self)
        self.skillByte = try container.decode(UInt8.self)
        self.skill = try container.decode(UInt8.self)
        self.skillID = try container.decode(UInt8.self)
        self.skillLevel = try container.decode(UInt8.self)
        self.skillParam = try container.decode(UInt8.self)
        let _ = try container.decode(UInt8.self)  // unused
        let _ = try container.decode(UInt8.self)  // unknown
        let _ = try container.decode(UInt32.self) // unknown
        self.startX = try container.decode(Int16.self)
        self.startY = try container.decode(Int16.self)

        let count = Int(try container.decode(UInt8.self))
        var movements: [Movement] = []
        movements.reserveCapacity(count)
        for _ in 0 ..< count {
            guard container.remainingBytes > 0 else { break }
            if let m = try? container.decode(Movement.self) {
                movements.append(m)
            } else {
                break
            }
        }
        self.movements = movements
    }
}
