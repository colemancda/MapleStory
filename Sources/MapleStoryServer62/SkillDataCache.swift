//
//  SkillDataCache.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation
import MapleStory

/// In-memory cache of WZ skill data, loaded once at server startup.
///
/// Usage:
/// ```swift
/// // At startup:
/// await SkillDataCache.shared.load(from: URL(fileURLWithPath: "/path/to/Skill.wz/extracted"))
///
/// // In handlers:
/// let skill = await SkillDataCache.shared.skill(id: 100100)
/// let level = await SkillDataCache.shared.level(skillID: 100100, level: 1)
/// ```
public actor SkillDataCache {

    public static let shared = SkillDataCache()

    private var skills: [UInt32: WzSkill] = [:]

    private init() {}

    /// Load all `*.img.xml` files from a directory (the extracted Skill.wz folder).
    /// Files that fail to parse are skipped with a warning.
    public func load(from directory: URL) async {
        let fm = FileManager.default

        // Get all XML files in the directory
        guard let files = try? fm.contentsOfDirectory(
            at: directory,
            includingPropertiesForKeys: nil
        ) else {
            print("SkillDataCache: unable to read directory \(directory.path)")
            return
        }

        var loaded = 0
        var bookCount = 0

        for url in files where url.pathExtension == "xml" {
            do {
                let book = try WzSkillBook(contentsOf: url)
                for skill in book.skills.values {
                    skills[skill.id] = skill
                    loaded += 1
                }
                bookCount += 1
            } catch {
                // skip files that don't match the skill book format
            }
        }

        print("SkillDataCache: loaded \(loaded) skills from \(bookCount) skill books at \(directory.path)")
    }

    /// Look up a skill by ID. Returns nil if not loaded.
    public func skill(id: UInt32) -> WzSkill? {
        skills[id]
    }

    /// Look up a specific skill level. Returns nil if skill or level not found.
    public func level(skillID: UInt32, level: Int) -> WzSkillLevel? {
        skills[skillID]?.levels[level]
    }

    /// Check if a skill is a buff skill (has duration > 0).
    public func isBuffSkill(_ skillID: UInt32, level: Int) -> Bool {
        guard let skillLevel = skills[skillID]?.levels[level] else { return false }
        return skillLevel.time > 0
    }

    /// Number of loaded skills.
    public var count: Int { skills.count }
}
