//
//  LoginHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import CoreModel
/*
public extension MapleStoryServer.Connection {
    
    func login(
        username: String,
        password: String
    ) async throws {
        
        log("Login - \(username)")
        let username = username.lowercased()
        
        // create if doesnt exist and autoregister enabled
        guard try await server.dataSource.register(username: username, password: request.password) == false else {
            log("Registered User - \(request.username)")
            await connection.authenticate(username: username)
            return
        }
        
        // check if user exists
        guard try await self.server.dataSource.userExists(for: username) else {
            throw MapleStoryError.unknownUser(username) //.success(username: request.username) // TODO: Failure
        }
        
        // validate password
        let password = try await self.server.dataSource.password(for: request.username)
        guard password == request.password else {
            throw MapleStoryError.invalidPassword //return .success(username: request.username) // TODO: Failure
        }
        
        await connection.authenticate(username: username)
    }
}

// MARK: - ModelStorage Extensions

internal extension ModelStorage {
    
    func serverLogin(
        username: String,
        password: String
    ) async throws {
        
    }
}
*/
