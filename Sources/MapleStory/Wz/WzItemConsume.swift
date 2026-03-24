//
//  WzItemConsume.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation

/// A single consumable item entry parsed from an `Item.wz/Consume/<group>.img.xml` file.
public struct WzItemConsume: Equatable, Sendable {

    public let id: UInt32

    // MARK: Info

    public let price: Int32
    public let slotMax: Int32
    public let isCash: Bool

    // MARK: Spec

    /// Flat HP recovery.
    public let hp: Int32
    /// Flat MP recovery.
    public let mp: Int32
    /// HP recovery as a percentage of max HP.
    public let hpRate: Int32
    /// MP recovery as a percentage of max MP.
    public let mpRate: Int32
    /// Buff duration in seconds.
    public let time: Int32
    /// EXP gain.
    public let exp: Int32
    /// Skill cancelled by the item (nuff skill).
    public let nuffSkill: Int32
    /// Map to move the player to (-1 = none).
    public let moveTo: Int32
    /// Chaos scroll chaos value (if applicable).
    public let chaosScrollSuccessRate: Int32
}

// MARK: - Parsing

public extension WzItemConsume {

    /// Parse a single item node (the child of the group `<imgdir>`).
    init(id: UInt32, node: WzNode) throws {
        self.id = id

        let infoNode = node["info"]
        func infoInt(_ key: String, default def: Int32 = 0) -> Int32 {
            infoNode?[key]?.intValue ?? def
        }
        self.price   = infoInt("price")
        self.slotMax = infoInt("slotMax", default: 100)
        self.isCash  = infoInt("cash") != 0

        let specNode = node["spec"]
        func specInt(_ key: String, default def: Int32 = 0) -> Int32 {
            specNode?[key]?.intValue ?? def
        }
        self.hp                     = specInt("hp")
        self.mp                     = specInt("mp")
        self.hpRate                 = specInt("hpRate")
        self.mpRate                 = specInt("mpRate")
        self.time                   = specInt("time")
        self.exp                    = specInt("exp")
        self.nuffSkill              = specInt("nuffSkill", default: -1)
        self.moveTo                 = specInt("moveTo", default: -1)
        self.chaosScrollSuccessRate = specInt("success")
    }

    /// Parse all items from a group file (e.g. `0200.img.xml`).
    /// Each top-level `<imgdir>` child is one item.
    static func items(from node: WzNode) throws -> [WzItemConsume] {
        try node.children.map { child in
            guard let id = UInt32(child.name) else {
                throw WzParseError.invalidValue(child.name, attribute: "name")
            }
            return try WzItemConsume(id: id, node: child)
        }
    }

    static func items(contentsOf url: URL) throws -> [WzItemConsume] {
        let node = try WzXMLParser().parse(contentsOf: url)
        return try items(from: node)
    }
}
