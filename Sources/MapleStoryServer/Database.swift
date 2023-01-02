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
        try await app.autoMigrate()
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
        guard try await userExists(for: username) else {
            return false
        }
        // check if can create new user
        
        // create new user
        let newUser = User(
            username: username,
            password: password
        )
        try await newUser.save(on: database)
        return true
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
    
    func worlds() throws -> [MapleStory.World] {
        []
    }
    
    func channel(_ id: MapleStory.Channel.ID, in world: MapleStory.World.ID) async throws -> MapleStory.Channel {
        fatalError()
    }
    
    func characters(for user: String) async throws -> [MapleStory.World.ID : [MapleStory.Character]] {
        [:]
    }
    
    func characters(for user: String, in world: MapleStory.World.ID, channel: MapleStory.Channel.ID) async throws -> [MapleStory.Character] {
        []
    }
}
