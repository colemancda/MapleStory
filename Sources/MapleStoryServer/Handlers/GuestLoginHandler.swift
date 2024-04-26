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
        let database = server.dataSource.storage
        let ipAddress = self.address.address
        // find guest user with ip address
        if let user = try await User.fetch(ipAddress: ipAddress, in: database), user.isGuest {
            
        }
        let userCount = try await database.count(User.self)
        let rawUsername = "Guest\(userCount)"
        guard let username = Username(rawValue: rawUsername),
              let password = Password(rawValue: rawUsername) else {
            fatalError("Invalid username or password \(rawUsername)")
        }
        // create new user
        let newUser = try await User.create(
            username: username,
            password: password,
            ipAddress: ipAddress,
            isGuest: true,
            in: database
        )
        return newUser
    }
}
