//
//  MoveLifeRequest.swift
//

import Foundation

/// Mob movement control packet sent by the controlling client.
public struct MoveLifeRequest: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ClientOpcode { .moveLife }

    public let objectID: UInt32
    public let moveID: UInt16
    public let skillByte: UInt8
    public let skill: UInt8
    public let skillID: UInt8
    public let skillLevel: UInt8
    public let skillParam: UInt8
    public let startX: Int16
    public let startY: Int16
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
        let _ = try container.decode(UInt8.self)
        let _ = try container.decode(UInt8.self)
        let _ = try container.decode(UInt32.self)
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
