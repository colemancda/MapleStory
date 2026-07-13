//
//  WzZmap.swift
//  MapleStoryFile
//
//  The global character-layer draw order from Base.wz/zmap.img: 149 layer names
//  (e.g. "body", "arm", "hair", "mailChest", "pants", "shoes") listed front to
//  back. A part's `z` string names its layer; higher index = further back, so
//  parts draw in descending-index order.
//

import Foundation

public struct WzZmap: Sendable {

    /// layer name -> index in the zmap (0 = frontmost).
    public let order: [String: Int]

    public init(order: [String: Int]) {
        self.order = order
    }

    /// The draw priority of a layer: higher = drawn earlier (further back).
    /// Unknown layers sort to the very back.
    public func priority(of layer: String) -> Int {
        order[layer] ?? Int.max
    }

    /// Load zmap.img from a Base.wz archive.
    public static func load(from baseArchive: WzArchive) throws -> WzZmap {
        guard let image = baseArchive.root["zmap.img"] else {
            return WzZmap(order: [:])
        }
        let props = try baseArchive.properties(of: image)
        var order: [String: Int] = [:]
        for (index, entry) in props.enumerated() {
            order[entry.name] = index
        }
        return WzZmap(order: order)
    }
}
