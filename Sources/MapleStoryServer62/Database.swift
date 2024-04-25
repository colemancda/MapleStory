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
/*
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
    
    private var characters: MongoCollection<Character.BSON>!
    
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
        self.characters = database.collection(Character.BSON.collection, withType: Character.BSON.self)
        // create worlds and channels
        if try await worldCollection.countDocuments() == 0 {
            let worlds = (0 ..< 15).map {
                let worldName = World.name(for: UInt8($0))
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
        // create admin user
        if try await userExists(for: "admin") == false {
            let user = User(
                username: "admin",
                password: "admin",
                isAdmin: true
            )
            try await users.insertOne(user)
            // create admin character in each world
            for world in try await _worlds() {
                let id = try await newCharacterID(in: world.index)
                let character = Character.BSON(
                    user: "admin",
                    world: world.index,
                    characterID: id,
                    name: "admin",
                    job: .supergm,
                    hp: 9999,
                    maxHp: 9999,
                    mp: 9999,
                    maxMp: 9999,
                    isMega: true,
                    isRankEnabled: false
                )
                try await characters.insertOne(character)
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
        try await _worlds().map { .init($0) }
    }
    
    func _worlds() async throws -> [World.BSON] {
        try await worldCollection.find().toArray()
    }
    
    func world(_ id: MapleStory.World.ID) async throws -> MapleStory.World {
        try await World(_world(id))
    }
    
    func _world(_ id: MapleStory.World.ID) async throws -> World.BSON {
        let filter: BSONDocument = [
            World.BSON.CodingKeys.index.rawValue: .int32(Int32(id))
        ]
        guard let world = try await worldCollection.findOne(filter) else {
            throw MapleStoryError.invalidRequest
        }
        return world
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
    
    func characters(
        for username: String
    ) async throws -> [MapleStory.World.ID : [MapleStory.Character]] {
        let characters = try await characters.find([
            "user": .string(username)
        ])
        .toArray()
        var results = [MapleStory.World.ID : [MapleStory.Character]]()
        for bson in characters {
            let value = Character(bson)
            results[bson.world, default: []].append(value)
        }
        return results
    }
    
    func characters(
        for username: String,
        in world: MapleStory.World.ID,
        channel: MapleStory.Channel.ID
    ) async throws -> [MapleStory.Character] {
        try await characters.find([
            "user": .string(username),
            "world": .int32(Int32(world))
        ])
        .toArray()
        .map { Character($0) }
    }
    
    func create(
        _ character: MapleStory.Character,
        for username: String,
        in worldID: World.ID
    ) async throws {
        let bson = Character.BSON(
            id: BSONObjectID(),
            user: username,
            world: worldID,
            characterID: character.id,
            name: character.name,
            created: character.created,
            gender: character.gender,
            skinColor: character.skinColor,
            face: character.face,
            hair: character.hair,
            hairColor: character.hairColor,
            level: character.level,
            job: character.job,
            str: character.str,
            dex: character.dex,
            int: character.int,
            luk: character.luk,
            hp: character.hp,
            maxHp: character.maxHp,
            mp: character.mp,
            maxMp: character.maxMp,
            ap: character.ap,
            sp: character.sp,
            exp: character.exp,
            fame: character.fame,
            isMarried: character.isMarried,
            currentMap: character.currentMap,
            spawnPoint: character.spawnPoint,
            isMega: character.isMega,
            cashWeapon: character.cashWeapon,
            equipment: character.equipment,
            maskedEquipment: character.maskedEquipment,
            isRankEnabled: character.isRankEnabled,
            worldRank: character.worldRank,
            rankMove: character.rankMove,
            jobRank: character.jobRank,
            jobRankMove: character.jobRankMove
        )
        try await characters.insertOne(bson)
    }
    
    func newCharacterID(in worldID: MapleStory.World.ID) async throws -> UInt32 {
        let filter: BSONDocument = [
            World.BSON.CodingKeys.index.rawValue: .int32(Int32(worldID))
        ]
        guard var world = try await worldCollection.findOne(filter) else {
            throw MapleStoryError.invalidRequest
        }
        world.maxCharacterID += 1
        try await worldCollection.findOneAndUpdate(filter: filter, update: worldCollection.encoder.encode(world))
        return world.maxCharacterID
    }
    
    func characterExists(
        name: String,
        in world: MapleStory.World.ID
    ) async throws -> Bool {
        let filter: BSONDocument = [
            "name": .string(name),
            "world": .int32(Int32(world))
        ]
        return try await characters.countDocuments(filter) != 0
    }
    
    func delete(
        character id: Character.ID,
        in world: World.ID
    ) async throws {
        let filter: BSONDocument = [
            "characterID": .int32(Int32(id)),
            "world": .int32(Int32(world))
        ]
        try await characters.deleteOne(filter)
    }
}
*/
