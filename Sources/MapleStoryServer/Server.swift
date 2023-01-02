//
//  Server.swift
//  
//
//  Created by Alsey Coleman Miller on 12/20/22.
//

import Foundation
import ArgumentParser
import MapleStory
import Socket
import struct Vapor.Environment

@main
struct Server: AsyncParsableCommand {
    
    static let configuration = CommandConfiguration(
        commandName: "MapleStoryServer",
        abstract: "MapleStory Server emulator",
        version: "1.0.0"
    )
    
    @Option(help: "Address to bind server.")
    var address: String?
    
    @Option(help: "Port to bind server.")
    var port: UInt16 = 8484
    
    @Option(help: "Server backlog.")
    var backlog: Int = 1000
    
    @Option(help: "Database host.")
    var databaseHost: String?
    
    @Option(help: "Database username.")
    var databaseUsername: String?
    
    @Option(help: "Database password.")
    var databasePassword: String?
    
    @Option(help: "Database name.")
    var databaseName: String?
    
    func run() async throws {
        
        // start server
        let ipAddress = self.address ?? IPv4Address.any.rawValue
        guard let address = MapleStoryAddress(address: ipAddress, port: port) else {
            throw MapleStoryError.invalidAddress(ipAddress)
        }
        
        let configuration = MapleStoryServerConfiguration(
            address: address,
            backlog: backlog
        )
        
        let database = try MapleStoryDatabase(
            host: (databaseHost ?? Environment.get("DATABASE_HOST")) ?? "localhost",
            name: (databaseName ?? Environment.get("DATABASE_NAME")) ?? "maplestory",
            username: (databaseUsername ?? Environment.get("DATABASE_USERNAME")) ?? "admin",
            password: (databasePassword ?? Environment.get("DATABASE_PASSWORD")) ?? "admin"
        )
        
        let server = try await MapleStoryServer(
            configuration: configuration,
            dataSource: database,
            socket: MapleStorySocketIPv4TCP.self
        )
        
        // create DB tables
        try await database.migrate()
        try await database.initialize()
        #if DEBUG
        NSLog("Users: \(try await database.userCount)")
        #endif
        try await Task.sleep(for: .seconds(Date.distantFuture.timeIntervalSinceNow))
        
        // retain
        let _ = server
    }
}
