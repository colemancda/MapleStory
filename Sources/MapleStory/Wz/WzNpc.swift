//
//  WzNpc.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation

/// NPC data parsed from a `Npc.wz/<id>.img.xml` file.
public struct WzNpc: Equatable, Sendable {

    public let id: UInt32

    /// Interaction click bounds (relative to origin).
    public struct Bounds: Equatable, Sendable {
        public let left: Int32
        public let top: Int32
        public let right: Int32
        public let bottom: Int32
    }
    public let bounds: Bounds

    /// Script entries keyed by dialogue index (0, 1, …).
    /// Value is the script filename (without `.js`).
    public let scripts: [Int: String]
}

// MARK: - Parsing

public extension WzNpc {

    init(id: UInt32, node: WzNode) throws {
        self.id = id

        let infoNode = node["info"]
        func int(_ key: String, default def: Int32 = 0) -> Int32 {
            infoNode?[key]?.intValue ?? def
        }
        self.bounds = Bounds(
            left:   int("dcLeft"),
            top:    int("dcTop"),
            right:  int("dcRight"),
            bottom: int("dcBottom")
        )

        var scripts: [Int: String] = [:]
        if let scriptDir = infoNode?["script"] {
            for child in scriptDir.children {
                guard let index = Int(child.name),
                      let name = child["script"]?.stringValue else { continue }
                scripts[index] = name
            }
        }
        self.scripts = scripts
    }

    init(contentsOf url: URL) throws {
        let filename = url.deletingPathExtension().deletingPathExtension().lastPathComponent
        guard let id = UInt32(filename) else {
            throw WzParseError.invalidValue(filename, attribute: "filename")
        }
        let node = try WzXMLParser().parse(contentsOf: url)
        try self.init(id: id, node: node)
    }
}
