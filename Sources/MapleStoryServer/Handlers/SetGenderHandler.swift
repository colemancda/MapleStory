//
//  SetGenderHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/29/24.
//

import Foundation
import CoreModel
import MapleStory

public extension MapleStoryServer.Connection {
    
    /// Handle setting gender of user account.
    func setGender(
        _ gender: Gender,
        didConfirm: Bool = true
    ) async throws -> User {
        
        log("Set Gender - \(gender)")
        
        let database = server.database
        
        guard var user = try await authenticatedUser() else {
            throw MapleStoryError.notAuthenticated
        }
        
        guard didConfirm else {
            throw MapleStoryError.invalidRequest
        }
        
        guard user.gender == nil else {
            throw MapleStoryError.invalidRequest
        }
        
        // store gender
        user.gender = gender
        try await database.insert(user)
        
        return user
    }
}
