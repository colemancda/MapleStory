//
//  FameResponseNotification.swift
//

import Foundation

/// Fame give/receive result notification.
///
/// status: 0=success(give), 1=bad username, 2=level too low, 3=daily limit, 4=monthly limit, 5=received fame, 6=unexpected error
public struct FameResponseNotification: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {

    public static var opcode: ServerOpcode { .fameResponse }

    public let status: UInt8

    /// Present when status == 0 (successfully gave fame).
    public let characterName: String?

    /// 0 = decrease, 1 = increase. Present when status == 0.
    public let mode: UInt8?

    /// New fame value. Present when status == 0.
    public let newFame: UInt16?
}
