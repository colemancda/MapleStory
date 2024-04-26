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
        username: Username,
        password: Password,
        autoregister: Bool = true
    ) async throws {
        let username = username.sanitized()
        let database = server.dataSource.storage
        let ipAddress = self.address.address
        
        // fetch existing user
        let user: User
        if var existingUser = try await User.fetch(username: username, in: database) {
            log("Login - \(username)")
            guard existingUser.isGuest == false else {
                // cannot login as guest
                throw MapleStoryError.invalidRequest //return .success(username: request.username) // TODO: Failure
            }
            // validate password
            guard try await User.validate(password: password, for: username, in: database) else {
                throw MapleStoryError.invalidPassword //return .success(username: request.username) // TODO: Failure
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
            throw MapleStoryError.unknownUser(username.rawValue)
        }
        
        assert(user.username == username)
        
        // upgrade connection
        await connection.authenticate(username: username)
    }
}
