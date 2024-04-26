//
//  LoginServer.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import ArgumentParser
import NIO
import MapleStoryServer
import Socket
import CoreModel
import MongoDBModel

struct LoginServerCommand: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "login",
        abstract: "Run the login server."
    )
    
    @Option(help: "Address to bind server.")
    var address: String?
    
    @Option(help: "Port to bind server.")
    var port: UInt16 = 8484
    
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
            version: .v62
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
        
        let server = try await MapleStoryServer<MapleStorySocketIPv4TCP, MongoModelStorage>(
            configuration: configuration,
            dataSource: .loginServer(storage: store),
            socket: MapleStorySocketIPv4TCP.self
        )
        
        try await Task.sleep(for: .seconds(Date.distantFuture.timeIntervalSinceNow))
        
        // retain
        //let _ = server
    }
}

public extension MapleStoryServer.DataSource {
    
    static func loginServer(
        storage: Storage
    ) -> MapleStoryServer.DataSource {
        Self.init(
            storage: storage,
            handlers: [
                MapleStoryServer.LoginHandler.self
            ]
        )
    }
}
