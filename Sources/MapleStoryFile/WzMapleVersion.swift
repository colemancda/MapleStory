//
//  WzMapleVersion.swift
//  MapleStoryFile
//
//  Ported from https://github.com/lastbattle/MapleLib (WzLib).
//

import Foundation

/// The encryption variant used by a WZ archive.
public enum WzMapleVersion: Sendable, Equatable {
    /// Global MapleStory.
    case gms
    /// MapleStory SEA / Europe.
    case ems
    /// "Classic" / private-server data with no string encryption.
    case bms
    /// A custom 4-byte IV.
    case custom([UInt8])
}

public extension WzMapleVersion {

    /// The 4-byte initialization vector seeding the string cipher.
    var initializationVector: [UInt8] {
        switch self {
        case .gms: return [0x4D, 0x23, 0xC7, 0x2B]
        case .ems: return [0xB9, 0x7D, 0x63, 0xE9]
        case .bms: return [0x00, 0x00, 0x00, 0x00]
        case .custom(let iv): return iv
        }
    }
}

/// WZ crypto constants (from MapleLib's `WzAESConstant` / `MapleCryptoConstants`).
public enum WzCrypto {

    /// Offset-decode constant.
    public static let offsetConstant: UInt32 = 0x581C_3F6D

    /// The 32-byte AES-256 key used for the string keystream, already trimmed from
    /// MapleLib's 128-byte `MAPLESTORY_USERKEY_DEFAULT` (every 16th byte).
    public static let aesUserKey: [UInt8] = [
        0x13, 0x00, 0x00, 0x00, 0x08, 0x00, 0x00, 0x00,
        0x06, 0x00, 0x00, 0x00, 0xB4, 0x00, 0x00, 0x00,
        0x1B, 0x00, 0x00, 0x00, 0x0F, 0x00, 0x00, 0x00,
        0x33, 0x00, 0x00, 0x00, 0x52, 0x00, 0x00, 0x00,
    ]
}
