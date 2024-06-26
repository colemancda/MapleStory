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
        
        let ipAddress = self.address.address
        let configuration = try await database.fetch(Configuration.self)
        let autoregister = configuration.isAutoRegisterEnabled ?? true
        
        // validate username
        guard let username = Username(rawValue: username) else {
            throw MapleStoryError.login(.invalidUsername)
        }
        
        // validate password
        guard let password = Password(rawValue: password) else {
            throw MapleStoryError.login(.invalidPassword)
        }
        
        // fetch existing user
        let user: User
        if var existingUser = try await User.fetch(username: username, in: database) {
            guard existingUser.isGuest == false else {
                // cannot login as guest
                throw MapleStoryError.login(.notRegistered)
            }
            // validate password
            guard try await User.validate(password: password, for: username, in: database) else {
                throw MapleStoryError.login(.invalidPassword)
            }
            // update IP address
            existingUser.ipAddress = ipAddress
            try await database.insert(existingUser)
            user = existingUser
        } else if autoregister {
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
            throw MapleStoryError.login(.notRegistered)
        }
        
        assert(user.username.rawValue.lowercased() == username.rawValue.lowercased())
        
        // check for ban
        
        
        // upgrade connection
        await authenticate(user: user)
        
        // check if terms of service was accepted
        guard user.termsAccepted else {
            throw MapleStoryError.login(.licenseAgreement)
        }
        
        return user
    }
}
