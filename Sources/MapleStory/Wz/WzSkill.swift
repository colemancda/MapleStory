//
//  WzSkill.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation

/// All skills for one job family parsed from a `Skill.wz/<job>.img.xml` file.
public struct WzSkillBook: Equatable, Sendable {

    public let skills: [UInt32: WzSkill]
}

/// A single skill and its per-level data.
public struct WzSkill: Equatable, Sendable {

    public let id: UInt32
    /// Maximum level (number of level entries in the file).
    public var maxLevel: Int { levels.count }
    public let levels: [Int: WzSkillLevel]
}

/// Stats for one level of a skill.
/// Field names follow the OdinMS convention (single letters are intentional).
public struct WzSkillLevel: Equatable, Sendable {

    /// HP cost percentage.
    public let hpCost: Int32
    /// MP cost.
    public let mpCost: Int32
    /// Primary stat value (damage %, speed boost, etc. — skill-specific).
    public let x: Int32
    /// Secondary stat value.
    public let y: Int32
    /// Tertiary stat value.
    public let z: Int32
    /// Quaternary stat value.
    public let w: Int32
    /// Damage percentage.
    public let damage: Int32
    /// Mastery percentage.
    public let mastery: Int32
    /// Number of attack hits.
    public let attackCount: Int32
    /// Number of bullets consumed.
    public let bulletCount: Int32
    /// Number of mobs hit.
    public let mobCount: Int32
    /// Buff duration in seconds.
    public let time: Int32
    /// Jump boost.
    public let jump: Int32
    /// Speed boost.
    public let speed: Int32
    /// Prop (probability / %).
    public let prop: Int32
    /// Range top-left x.
    public let ltX: Int32
    /// Range top-left y.
    public let ltY: Int32
    /// Range bottom-right x.
    public let rbX: Int32
    /// Range bottom-right y.
    public let rbY: Int32
}

// MARK: - Parsing

public extension WzSkillBook {

    init(node: WzNode) throws {
        guard let skillDir = node["skill"] else {
            throw WzParseError.missingAttribute("skill", element: node.name)
        }
        var skills: [UInt32: WzSkill] = [:]
        for child in skillDir.children {
            guard let id = UInt32(child.name) else { continue }
            let skill = try WzSkill(id: id, node: child)
            skills[id] = skill
        }
        self.skills = skills
    }

    init(contentsOf url: URL) throws {
        let node = try WzXMLParser().parse(contentsOf: url)
        try self.init(node: node)
    }
}

public extension WzSkill {

    init(id: UInt32, node: WzNode) throws {
        self.id = id
        var levels: [Int: WzSkillLevel] = [:]
        if let levelDir = node["level"] {
            for child in levelDir.children {
                guard let lvl = Int(child.name) else { continue }
                levels[lvl] = WzSkillLevel(node: child)
            }
        }
        self.levels = levels
    }
}

extension WzSkillLevel {

    init(node: WzNode) {
        func i(_ key: String) -> Int32 { node[key]?.intValue ?? 0 }
        hpCost      = i("hp")
        mpCost      = i("mp")
        x           = i("x")
        y           = i("y")
        z           = i("z")
        w           = i("w")
        damage      = i("damage")
        mastery     = i("mastery")
        attackCount = i("attackCount")
        bulletCount = i("bulletCount")
        mobCount    = i("mobCount")
        time        = i("time")
        jump        = i("jump")
        speed       = i("speed")
        prop        = i("prop")
        ltX         = node["lt"]?.vectorX ?? 0
        ltY         = node["lt"]?.vectorY ?? 0
        rbX         = node["rb"]?.vectorX ?? 0
        rbY         = node["rb"]?.vectorY ?? 0
    }
}
