//
//  Database.swift
//  
//
//  Created by Alsey Coleman Miller on 12/30/22.
//

import Foundation
import ArgumentParser
import MapleStory
import Fluent
import FluentPostgresDriver
import Vapor

final class MapleStoryDatabase: MapleStoryServerDataSource {
    
    let host: String
    
    let name: String
    
    let username: String
    
    let password: String
    
    private let app: Application
    
    private var database: Database {
        app.db(.psql)
    }
    
    init(
        host: String,
        name: String,
        username: String,
        password: String
    ) throws {
        self.host = host
        self.name = name
        self.username = username
        self.password = password
        // setup app
        var env = try Environment.detect()
        try LoggingSystem.bootstrap(from: &env)
        self.app = Application(env)
        app.databases.use(
            .postgres(
                hostname: host,
                username: username,
                password: password,
                database: name
            ),
            as: .psql
        )
        #if DEBUG
        app.logger.logLevel = .debug
        #endif
    }
    
    func run() throws {
        defer { app.shutdown() }
        try app.run()
    }
    
    func migrate() async throws {
        app.migrations.add(CreateUser())
        app.migrations.add(CreateWorld())
        app.migrations.add(CreateChannel())
        try await app.autoMigrate()
    }
    
    func initialize() async throws {
        // create admin user
        if try await userExists(for: "admin") == false {
            try await createUser(
                username: "admin",
                password: "admin"
            )
        }
        // create worlds
        if try await worlds().isEmpty {
            for worldIndex in 0 ..< 15 {
                let world = World(
                    index: numericCast(worldIndex),
                    name: "World \(worldIndex + 1)"
                )
                try await world.create(on: database)
                // create channels
                for channelIndex in 0 ..< 20 {
                    let channel = Channel(world: world.id!, name: "\(world.name) - \(channelIndex + 1)")
                    try await world.$channels.create(channel, on: database)
                }
                // save
                try await world.save(on: database)
            }
        }
    }
    
    var command: ArgumentParser.ParsableCommand.Type {
        fatalError()
    }
    
    func didConnect(_ address: MapleStory.MapleStoryAddress) {
        
    }
    
    func didDisconnect(_ address: MapleStory.MapleStoryAddress, username: String?) {
        
    }
    
    func register(
        username: String,
        password: String
    ) async throws -> Bool {
        // check if user exists
        guard try await userExists(for: username) == false else {
            return false
        }
        // check if can create new user
        
        // create new user
        try await createUser(username: username, password: password)
        return true
    }
    
    func createUser(
        username: String,
        password: String
    ) async throws {
        // create new user
        let newUser = User(
            username: username,
            password: password
        )
        try await newUser.create(on: database)
    }
    
    func password(for username: String) async throws -> String {
        let user = try await user(for: username)
        return user.password
    }
    
    func pin(for username: String) async throws -> String {
        let user = try await user(for: username)
        return user.pinCode
    }
    
    func userExists(for username: String) async throws -> Bool {
        let username = username.lowercased()
        let count = try await User
            .query(on: database)
            .filter(\.$username, .equal, username)
            .count()
        return count != 0
    }
    
    func user(for username: String) async throws -> User {
        let username = username.lowercased()
        guard let user = try await User
            .query(on: database)
            .filter(\.$username, .equal, username)
            .first() else {
            throw MapleStoryError.unknownUser(username)
        }
        return user
    }
    
    var userCount: Int {
        get async throws {
            try await User
                .query(on: database)
                .count()
        }
    }
    
    func worlds() async throws -> [MapleStory.World] {
        let worlds = try await World
            .query(on: database)
            .sort(\.$index)
            .all()
        var result = [MapleStory.World]()
        result.reserveCapacity(worlds.count)
        for value in worlds {
            let mappedValue = MapleStory.World(
                id: numericCast(value.index),
                name: value.name,
                address: value.address,
                flags: numericCast(value.flags),
                eventMessage: value.eventMessage,
                rateModifier: numericCast(value.rateModifier),
                eventXP: numericCast(value.eventXP),
                dropRate: numericCast(value.dropRate),
                channels: try await value.$channels.query(on: database).all().enumerated().map { (index, channel) in
                    MapleStory.Channel(
                        id: numericCast(index),
                        name: channel.name,
                        load: numericCast(channel.load),
                        status: channel.status
                    )
                }
            )
            result.append(mappedValue)
        }
        return result
    }
    
    func world(_ id: MapleStory.World.ID) async throws -> MapleStory.World {/*
        guard let value = try await World
            .query(on: database)
            .filter(\World.index, .equal, Int(id))
            .first() else {
            throw MapleStoryError.invalidRequest
        }
        return MapleStory.World(
            id: numericCast(value.index),
            name: value.name,
            address: value.address,
            flags: numericCast(value.flags),
            eventMessage: value.eventMessage,
            rateModifier: numericCast(value.rateModifier),
            eventXP: numericCast(value.eventXP),
            dropRate: numericCast(value.dropRate),
            channels: try await value.$channels.query(on: database).all().enumerated().map { (index, channel) in
                MapleStory.Channel(
                    id: numericCast(index),
                    name: channel.name,
                    load: numericCast(channel.load),
                    status: channel.status
                )
            }
        )*/
        fatalError()
    }
    
    func channel(
        _ channelID: MapleStory.Channel.ID,
        in worldID: MapleStory.World.ID
    ) async throws -> MapleStory.Channel {
        guard let world = try await World
            .query(on: database)
            .filter(\.$index, .equal, Int(worldID))
            .first() else {
            throw MapleStoryError.invalidRequest
        }
        let channels = try await world.$channels.query(on: database).all()
        let values = channels.enumerated().map { (index, channel) in
            MapleStory.Channel(
                id: UInt8(index),
                name: channel.name,
                load: numericCast(channel.load),
                status: channel.status
            )
        }
        guard let channel = values.first(where: { $0.id == channelID }) else {
            throw MapleStoryError.invalidRequest
        }
        return channel
    }
    
    func characters(for user: String) async throws -> [MapleStory.World.ID : [MapleStory.Character]] {
        [:]
    }
    
    func characters(for user: String, in world: MapleStory.World.ID, channel: MapleStory.Channel.ID) async throws -> [MapleStory.Character] {
        []
    }
    
    func create(_ character: MapleStory.Character) async throws {
        
    }
    
    func newCharacterID(in world: MapleStory.World.ID) async throws -> UInt32 {
        0
    }
    
    func characterExists(name: String, in world: MapleStory.World.ID) async throws -> Bool {
        return false
    }
}
