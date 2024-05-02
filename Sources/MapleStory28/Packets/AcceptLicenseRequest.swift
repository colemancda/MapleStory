//
//  AcceptLicenseRequest.swift
//  
//
//  Created by Alsey Coleman Miller on 5/2/24.
//

import Foundation
import MapleStory

public struct AcceptLicenseRequest: MapleStoryPacket, Codable, Equatable, Hashable, Sendable {
    
    public static var opcode: ClientOpcode { .acceptLicense }
    
    public let didAccept: Bool
    
    public init(didAccept: Bool = true) {
        self.didAccept = didAccept
    }
}
