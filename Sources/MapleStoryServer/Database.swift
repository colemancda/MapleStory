//
//  Database.swift
//  
//
//  Created by Alsey Coleman Miller on 12/30/22.
//

import Foundation
import ArgumentParser
import MapleStory
import SwiftBSON
import MongoSwift
import NIOPosix

final class MapleStoryDatabase: MapleStoryServerDataSource {
    
    let url: URL
    
    let name: String
    
    let username: String?
    
    let password: String?
    
    private let client: MongoClient
    
    private let eventLoopGroup: MultiThreadedEventLoopGroup
    
    private let database: MongoDatabase
    
    private var users: MongoCollection<User>!
    
    private var worldCollection: MongoCollection<World.BSON>!
    
    deinit {
        // clean up driver resources
        try? client.syncClose()
        // shut down EventLoopGroup
        try? eventLoopGroup.syncShutdownGracefully()
    }
    
    init(
        url: URL = URL(string: "mongodb://localhost:27017")!,
        name: String = "maplestory",
        username: String? = nil,
        password: String? = nil
    ) async throws {
        self.url = url
        self.name = name
        self.username = username
        self.password = password
        // setup db
        let eventLoopGroup = MultiThreadedEventLoopGroup(numberOfThreads: 4)
        self.client = try MongoClient(url.absoluteString, using: eventLoopGroup)
        self.eventLoopGroup = eventLoopGroup
        self.database = client.db(name)
        try await initialize()
    }
    
    func initialize() async throws {
        // setup tables
        self.users = database.collection(User.collection, withType: User.self)
        self.worldCollection = database.collection(World.BSON.collection, withType: World.BSON.self)
        // create admin user
        if try await userExists(for: "admin") == false {
            let user = User(
                username: "admin",
                password: "admin",
                isAdmin: true
            )
            try await users.insertOne(user)
            // create admin character
            
        }
        // create worlds and channels
        if try await worldCollection.countDocuments() == 0 {
            let worlds = (0 ..< 15).map {
                let worldName = "World \($0 + 1)"
                var address = MapleStoryAddress.channelServerDefault
                address.port += UInt16($0)
                return World.BSON(
                    index: World.ID($0),
                    name: worldName,
                    address: address,
                    channels: (0 ..< 20).map {
                        Channel.BSON(
                            name: "\(worldName) - \($0 + 1)",
                            load: 0,
                            status: .normal
                        )
                    }
                )
            }
            try await worldCollection.insertMany(worlds)
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
        let username = username.lowercased()
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
        let username = username.lowercased()
        // create new user
        let newUser = User(
            username: username,
            password: password
        )
        try await users.insertOne(newUser)
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
        let filter: BSONDocument = [
            User.CodingKeys.username.rawValue: .string(username)
        ]
        let count = try await users.countDocuments(filter)
        return count != 0
    }
    
    func user(for username: String) async throws -> User {
        let username = username.lowercased()
        let filter: BSONDocument = [
            User.CodingKeys.username.rawValue: .string(username)
        ]
        guard let user = try await users.findOne(filter) else {
            throw MapleStoryError.unknownUser(username)
        }
        return user
    }
    
    var userCount: Int {
        get async throws {
            try await users.countDocuments()
        }
    }
    
    func worlds() async throws -> [MapleStory.World] {
        try await worldCollection.find().toArray().map { .init($0) }
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
        let filter: BSONDocument = [
            World.BSON.CodingKeys.index.rawValue: .int32(Int32(worldID))
        ]
        guard let world = try await worldCollection.findOne(filter),
              let channel = world.channels
                .enumerated()
                .first(where: { $0.offset == channelID })
                .flatMap({ Channel(id: UInt8($0.offset), $0.element) }) else {
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
