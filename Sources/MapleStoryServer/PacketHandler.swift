//
//  PacketHandler.swift
//
//
//  Created by Alsey Coleman Miller on 4/25/24.
//

import Foundation

public protocol PacketHandler {
    
    associatedtype Event
    
    init(event: Event)
    
    func evaluate() async throws
}
