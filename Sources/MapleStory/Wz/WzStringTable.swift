//
//  WzStringTable.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation

/// Name/description strings for a category of game objects,
/// parsed from a `String.wz/<Type>.img.xml` file.
///
/// Covers `Mob.img.xml`, `Npc.img.xml`, `Map.img.xml`, `Skill.img.xml`,
/// `Consume.img.xml`, `Etc.img.xml`, `Eqp.img.xml`, `Cash.img.xml`.
public struct WzStringTable: Equatable, Sendable {

    public struct Entry: Equatable, Sendable {
        public let name: String
        public let description: String
        /// Extra string fields keyed by their attribute name (e.g. `"func"`, `"streetName"`, `"n0"`).
        public let extra: [String: String]
    }

    /// Entries keyed by the numeric string ID found in the XML (e.g. `"100100"`, `"1012000"`).
    public let entries: [String: Entry]
}

// MARK: - Lookup

public extension WzStringTable {

    subscript(id: String) -> Entry? { entries[id] }

    func name(for id: String) -> String? { entries[id]?.name }
}

// MARK: - Parsing

public extension WzStringTable {

    /// Parse from the root node of a `String.wz` file.
    ///
    /// Handles both flat layouts (`Mob.img.xml`, `Npc.img.xml`)
    /// and nested category layouts (`Eqp.img.xml` → `Eqp` → `Accessory` → `<id>`,
    /// `Map.img.xml` → `<streetCategory>` → `<mapId>`).
    init(node: WzNode) {
        var entries: [String: Entry] = [:]
        WzStringTable.collect(node.children, into: &entries)
        self.entries = entries
    }

    private static func collect(_ nodes: [WzNode], into entries: inout [String: Entry]) {
        for node in nodes {
            // If the name is a numeric ID, treat it as an entry.
            if UInt32(node.name) != nil || (node.name.count > 3 && Int(node.name) != nil) {
                if let entry = makeEntry(node) {
                    entries[node.name] = entry
                    continue
                }
            }
            // Otherwise recurse into the directory.
            collect(node.children, into: &entries)
        }
    }

    private static func makeEntry(_ node: WzNode) -> Entry? {
        var name = ""
        var desc = ""
        var extra: [String: String] = [:]
        for child in node.children {
            guard let v = child.stringValue else { continue }
            switch child.name {
            case "name":        name = v
            case "desc":        desc = v
            default:            extra[child.name] = v
            }
        }
        guard !name.isEmpty else { return nil }
        return Entry(name: name, description: desc, extra: extra)
    }

    init(contentsOf url: URL) throws {
        let node = try WzXMLParser().parse(contentsOf: url)
        self.init(node: node)
    }
}
