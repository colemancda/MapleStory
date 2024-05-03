//
//  ChannelServer.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation
import ArgumentParser
import NIO
import Socket
import CoreModel
import MongoDBModel
import MapleStory83
import MapleStoryServer

struct ChannelServerCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "channel",
        abstract: "Run the channel server."
    )
    
    @Option(help: "World Index")
    var world: Int = 1
    
    @Option(help: "Channel Index")
    var channel: Int = 1
    
    @Option(help: "Address to bind server.")
    var address: String?
    
    @Option(help: "Port to bind server.")
    var port: UInt16 = 7575
    
    @Option(help: "Server backlog.")
    var backlog: Int = 1000
    
    @Option(help: "Database URL.")
    var databaseURL: String = "mongodb://localhost:27017"
    
    @Option(help: "Database username.")
    var databaseUsername: String?
    
    @Option(help: "Database password.")
    var databasePassword: String?
    
    @Option(help: "Database name.")
    var databaseName: String = "maplestory"
    
    func validate() throws {
        if let address {
            guard let _ = MapleStoryAddress(address: address, port: port) else {
                throw MapleStoryError.invalidAddress(address)
            }
        }
        guard world > 0 else {
            throw MapleStoryError.invalidWorld
        }
        guard channel > 0 else {
            throw MapleStoryError.invalidChannel
        }
    }
    
    func run() async throws {
        
        defer { cleanupMongoSwift() }
        
        // start server
        let ipAddress = self.address ?? IPv4Address.any.rawValue
        guard let address = MapleStoryAddress(address: ipAddress, port: port) else {
            throw MapleStoryError.invalidAddress(ipAddress)
        }
        
        let configuration = ServerConfiguration(
            address: address,
            backlog: backlog,
            version: .v83
        )
        
        let elg = MultiThreadedEventLoopGroup(numberOfThreads: 2)
        
        defer {
            try? elg.syncShutdownGracefully()
        }
        
        let mongoClient = try MongoClient(
            databaseURL,
            using: elg,
            options: MongoClientOptions(
                credential: MongoCredential(
                    username: databaseUsername,
                    password: databasePassword
                )
            )
        )
        
        defer {
            try? mongoClient.syncClose()
        }
        
        let store = MongoModelStorage(
            database: mongoClient.db(databaseName),
            model: .mapleStory
        )
        
        let server = try await MapleStoryServer<MapleStorySocketIPv4TCP, MongoModelStorage, ClientOpcode, ServerOpcode>(
            configuration: configuration,
            database: store,
            socket: MapleStorySocketIPv4TCP.self
        )
                
        guard let world = try await World.fetch(
            index: World.Index(self.world - 1),
            version: configuration.version,
            region: configuration.region,
            in: store
        ) else {
            throw MapleStoryError.invalidWorld
        }
        
        await server.registerChannelServer(
            world: world.id
        )
        
        try await Task.sleep(for: .seconds(Date.distantFuture.timeIntervalSinceNow))
        
        // retain
        let _ = server
    }
}

public extension MapleStoryServer {
    
    func registerChannelServer(
        world: World.ID
    ) async {
        //await register(HandshakeHandler())
        //await register(PingHandler())
        
    }
}
