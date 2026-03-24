//
//  WzMob.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation

/// Mob stats parsed from a `Mob.wz/<id>.img.xml` file.
public struct WzMob: Equatable, Sendable {

    /// Mob ID derived from the filename (e.g. `0100100`).
    public let id: UInt32

    public let maxHP: Int32
    public let maxMP: Int32
    public let exp: Int32
    public let level: Int32
    public let speed: Int32

    /// Physical attack damage.
    public let paDamage: Int32
    /// Physical defense.
    public let pdDamage: Int32
    /// Magic attack damage.
    public let maDamage: Int32
    /// Magic defense.
    public let mdDamage: Int32

    public let accuracy: Int32
    public let evasion: Int32

    public let isUndead: Bool
    public let isPushed: Bool
    public let bodyAttack: Bool

    /// Movement speed multiplier (`fs` field).
    public let floatSpeed: Float
}

// MARK: - Parsing

public extension WzMob {

    /// Parse a mob from the root node of a `Mob.wz/<id>.img.xml` file.
    /// `id` is the numeric mob ID (from the filename).
    init(id: UInt32, node: WzNode) throws {
        guard let info = node["info"] else {
            throw WzParseError.missingAttribute("info", element: node.name)
        }
        func int(_ key: String, default def: Int32 = 0) -> Int32 {
            info[key]?.intValue ?? def
        }
        self.id = id
        self.maxHP       = int("maxHP")
        self.maxMP       = int("maxMP")
        self.exp         = int("exp")
        self.level       = int("level")
        self.speed       = int("speed")
        self.paDamage    = int("PADamage")
        self.pdDamage    = int("PDDamage")
        self.maDamage    = int("MADamage")
        self.mdDamage    = int("MDDamage")
        self.accuracy    = int("acc")
        self.evasion     = int("eva")
        self.isUndead    = int("undead") != 0
        self.isPushed    = int("pushed") != 0
        self.bodyAttack  = int("bodyAttack") != 0
        self.floatSpeed  = info["fs"]?.floatValue ?? 0
    }

    /// Parse a mob from a `Mob.wz/<id>.img.xml` file URL.
    /// The mob ID is extracted from the filename.
    init(contentsOf url: URL) throws {
        let filename = url.deletingPathExtension().deletingPathExtension().lastPathComponent
        guard let id = UInt32(filename) else {
            throw WzParseError.invalidValue(filename, attribute: "filename")
        }
        let node = try WzXMLParser().parse(contentsOf: url)
        try self.init(id: id, node: node)
    }
}
