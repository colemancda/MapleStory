//
//  LoginHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import CoreModel

public extension MapleStoryServer.Connection {
    
    /// Handle a user logging in.
    func login(
        username: Username,
        password: Password
    ) async throws {
        let username = username.sanitized()
        let database = server.dataSource.storage
        log("Login - \(username)")
        
        // create if doesnt exist and autoregister enabled
        guard try await User.register(username: username, password: password, in: database) == false else {
            log("Registered User - \(username)")
            await connection.authenticate(username: username)
            return
        }
        
        // check if user exists
        guard try await User.exists(with: username, in: database) else {
            throw MapleStoryError.unknownUser(username.rawValue) //.success(username: request.username) // TODO: Failure
        }
        
        // validate password
        guard try await User.validate(password: password, for: username, in: database) else {
            throw MapleStoryError.invalidPassword //return .success(username: request.username) // TODO: Failure
        }
        
        await connection.authenticate(username: username)
    }
}
