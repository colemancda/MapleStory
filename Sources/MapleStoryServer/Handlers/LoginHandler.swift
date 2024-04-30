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
        password: String
    ) async throws -> User {
        
        log("Login - \(username)")
        
        let database = server.database
        let ipAddress = self.address.address
        let configuration = try await database.fetch(Configuration.self)
        let autoregister = configuration.isAutoRegisterEnabled ?? true
        
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
                throw LoginError.invalidUsername
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
                
        // check for ban
        
        
        // upgrade connection
        await connection.authenticate(username: user.username)
        
        // check if terms of service was accepted
        guard user.termsAccepted else {
            throw LoginError.licenseAgreement
        }
        
        return user
    }
}

public extension MapleStoryServer.Connection {
    
    func authenticatedUser() async throws -> User? {
        guard let username = await self.connection.username else {
            return nil
        }
        return try await User.fetch(username: username.rawValue, in: server.database)
    }
}
