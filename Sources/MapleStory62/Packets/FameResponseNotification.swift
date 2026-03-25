//
//  FameResponseNotification.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Response to a fame operation, sent to the giver or receiver.
///
/// All three cases share the same opcode (`FAME_RESPONSE`).
/// The first byte of the payload determines the variant.
///
/// # Status Codes (error case)
///
/// | Status | Meaning |
/// |--------|---------|
/// | 1      | Invalid username |
/// | 2      | Under level 15 |
/// | 3      | Already gave fame today |
/// | 4      | Already gave fame to this character this month |
/// | 6      | Unexpected error |
public enum FameResponseNotification: MapleStoryPacket, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .fameResponse }

    /// Sent to the giver on success: status(0) + targetName + mode + newFame + padding(0)
    case success(targetName: CharacterName, mode: UInt8, newFame: UInt16)

    /// Sent to the giver on failure: status(1–4, 6)
    case error(UInt8)

    /// Sent to the receiver: status(5) + giverName + mode
    case received(fromName: CharacterName, mode: UInt8)
}

// MARK: - MapleStoryEncodable

extension FameResponseNotification: MapleStoryEncodable {

    public func encode(to container: MapleStoryEncodingContainer) throws {
        switch self {
        case let .success(targetName, mode, newFame):
            try container.encode(UInt8(0))
            try container.encode(targetName)
            try container.encode(mode)
            try container.encode(newFame)
            try container.encode(UInt16(0))
        case let .error(status):
            try container.encode(status)
        case let .received(fromName, mode):
            try container.encode(UInt8(5))
            try container.encode(fromName)
            try container.encode(mode)
        }
    }
}
