//
//  GuestLoginHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/26/24.
//

import Foundation
import CoreModel
import MapleStory

public extension MapleStoryServer.Connection {
    
    /// Handle guest login.
    func guestLogin() async throws -> User {
        log("Guest Login")
        let ipAddress = self.address.address
        // find guest user with ip address
        let user: User
        if let existingUser = try await User.fetch(ipAddress: ipAddress, in: database).first(where: { $0.isGuest }) {
            user = existingUser
        } else {
            // create new guest user
            let userCount = try await database.fetch(configuration: .lastUserIndex)?.intValue ?? 1
            let rawUsername = "Guest\(userCount)"
            let rawPassword = "Guest\(Int(Date().timeIntervalSince1970))"
            guard let username = Username(rawValue: rawUsername),
                  let password = Password(rawValue: rawPassword) else {
                fatalError("Invalid username or password \(rawUsername) \(rawPassword)")
            }
            // create new user
            user = try await User.create(
                username: username,
                password: password,
                ipAddress: ipAddress,
                isGuest: true,
                in: database
            )
        }
        
        // stay logged in as user
        await authenticate(user: user)
        
        return user
    }
}
