//
//  PinCodeHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/28/24.
//

import Foundation
import CoreModel
import MapleStory

public extension MapleStoryServer.Connection {
    
    /// Handle a user logging in.
    func pinCodeStatus(
        _ input: String,
        for username: String
    ) async throws -> PinCodeStatus {
        
        log("Check Pin - \(username)")
        
        let database = server.database
        let ipAddress = self.address.address
        let configuration = try await database.fetch(Configuration.self)
        let isPinEnabled = configuration.isPinEnabled ?? false
        
        guard isPinEnabled else {
            return .success
        }
        
        guard let user = try await authenticatedUser() else {
            return .systemError
        }
        
        guard let pinCode = user.pinCode else {
            return .register
        }
        
        guard user.ipAddress == ipAddress else {
            return .enterPin
        }
        
        guard pinCode == input else {
            return .invalid
        }
        
        return .success
    }
}
