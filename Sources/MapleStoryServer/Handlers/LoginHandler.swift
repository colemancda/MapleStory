//
//  LoginHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation
import CoreModel
import MapleStory

public extension MapleStoryServer.Connection {
    
    /// Handle a user logging in.
    func login(
        username: String,
        password: String,
        autoregister: Bool = true
    ) async throws {
        
        log("Login - \(username)")
        
        let database = server.dataSource.storage
        let ipAddress = self.address.address
        
        // fetch existing user
        let user: User
        if var existingUser = try await User.fetch(username: username, in: database) {
            guard existingUser.isGuest == false else {
                // cannot login as guest
                throw LoginError.notRegistered
            }
            // validate password
            guard try await User.validate(password: password, for: username, in: database) else {
                throw LoginError.invalidPassword
            }
            // update IP address
            existingUser.ipAddress = ipAddress
            try await database.insert(existingUser)
            user = existingUser
        } else if autoregister {
            // validate username
            guard let username = Username(rawValue: username) else {
                throw LoginError.blocked
            }
            // validate password
            guard let password = Password(rawValue: password) else {
                throw LoginError.invalidPassword
            }
            // auto register
            let newUser = try await User.create(
                username: username,
                password: password,
                ipAddress: ipAddress,
                in: database
            )
            log("Registered User - \(username)")
            user = newUser
        } else {
            throw LoginError.notRegistered
        }
        
        assert(user.username.rawValue.lowercased() == username.lowercased())
        
        // upgrade connection
        await connection.authenticate(username: user.username)
    }
}
