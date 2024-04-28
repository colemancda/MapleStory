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
        let database = server.database
        let ipAddress = self.address.address
        // find guest user with ip address
        let user: User
        if let existingUser = try await User.fetch(ipAddress: ipAddress, in: database), existingUser.isGuest {
            user = existingUser
        } else {
            // create new guest user
            let userCount = try await database.count(User.self)
            let rawUsername = "Guest\(userCount)"
            guard let username = Username(rawValue: rawUsername),
                  let password = Password(rawValue: rawUsername) else {
                fatalError("Invalid username or password \(rawUsername)")
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
        // check if terms of service was accepted
        guard user.termsAccepted else {
            throw LoginError.licenseAgreement
        }
        return user
    }
}
