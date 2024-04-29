//
//  AcceptLicenseHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import MapleStory

public extension MapleStoryServer.Connection {
    
    /// Accept license.
    func acceptLicense() async throws -> User {
        guard var user = try await self.authenticatedUser() else {
            throw MapleStoryError.notAuthenticated
        }
        guard user.termsAccepted == false else {
            throw MapleStoryError.invalidRequest
        }
        // accept terms
        user.termsAccepted = true
        try await server.database.insert(user)
        return user
    }
}
