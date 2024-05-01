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
    
    /// Handle a pin code check.
    func pinCodeStatus(
        _ input: String?
    ) async throws -> PinCodeStatus {
        
        log("Check Pin")
        
        let ipAddress = self.address.address
        let isPinEnabled = try await database.fetch(configuration: .pinEnabled)?.boolValue ?? false
        
        guard isPinEnabled else {
            return .success
        }
        
        guard let user = try await self.user else {
            return .systemError
        }
        
        guard let pinCode = user.pinCode else {
            return .register
        }
        
        guard user.ipAddress == ipAddress else {
            return .enterPin
        }
        
        guard let input else {
            return .enterPin
        }
        
        guard pinCode == input else {
            return .invalid
        }
        
        return .success
    }
}
