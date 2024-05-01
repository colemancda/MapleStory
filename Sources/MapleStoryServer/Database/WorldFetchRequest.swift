//
//  WorldFetchRequest.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import CoreModel
import MapleStory

// MARK: - Predicate

public extension World {
    
    enum Predicate {
        
        case index(World.Index)
        case version(MapleStory.Version)
        case region(MapleStory.Region)
    }
}

public extension FetchRequest.Predicate {
    
    init(predicate: World.Predicate) {
        switch predicate {
        case .index(let index):
            self = World.CodingKeys.index.stringValue.compare(.equalTo, .attribute(.int16(numericCast(index))))
        case .region(let region):
            self = World.CodingKeys.region.stringValue.compare(.equalTo, .attribute(.int16(numericCast(region.rawValue))))
        case .version(let version):
            self = World.CodingKeys.version.stringValue.compare(.equalTo, .attribute(.int32(numericCast(version.rawValue))))
        }
    }
}

// MARK: - Storage

public extension World {
    
    static func fetch<Storage: ModelStorage>(
        index: World.Index,
        version: MapleStory.Version,
        region: MapleStory.Region,
        in context: Storage
    ) async throws -> World? {
        let predicates: [World.Predicate] = [
            .index(index),
            .version(version),
            .region(region)
        ]
        return try await context.fetch(
            World.self,
            predicate: .compound(.and(predicates.map { .init(predicate: $0) })),
            fetchLimit: 1
        ).first
    }
    
    static func fetch<Storage: ModelStorage>(
        version: MapleStory.Version,
        region: MapleStory.Region,
        in context: Storage
    ) async throws -> [World] {
        let predicates: [World.Predicate] = [
            .version(version),
            .region(region)
        ]
        let sortDescriptors = [
            FetchRequest.SortDescriptor(
                property: PropertyKey(World.CodingKeys.index),
                ascending: true
            )
        ]
        return try await context.fetch(
            World.self,
            sortDescriptors: sortDescriptors,
            predicate: .compound(.and(predicates.map { .init(predicate: $0) }))
        )
    }
    
    @discardableResult
    static func insert<Storage: ModelStorage>(
        worlds names: [World.Name] = World.Name.allCases,
        region: Region = .global,
        version: Version,
        address: String,
        in context: Storage
    ) async throws -> [World] {
        let worlds = names
            .filter { $0.isCompatible(for: version) }
            .enumerated()
            .map { (index, name) in
            let worldAddress = MapleStoryAddress(
                address: address,
                port: 7575 + UInt16(index)
            ) ?? .channelServerDefault
            return World(
                id: UUID(),
                index: name.index,
                name: name.rawValue,
                region: region,
                version: version,
                address: worldAddress
            )
        }
        // insert new worlds
        for var world in worlds {
            // create world
            try await context.insert(world)
            // insert channels
            for channelIndex in 0 ..< 20 {
                let channel = Channel(
                    index: numericCast(channelIndex),
                    world: world.id,
                    name: world.name + " - Channel \(channelIndex + 1)"
                )
                world.channels.append(channel.id)
                // save world and channel
                try await context.insert(channel)
                try await context.insert(world)
            }
        }
        return worlds
    }
}
