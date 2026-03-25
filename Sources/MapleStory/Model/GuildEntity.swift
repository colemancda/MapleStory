//
//  GuildEntity.swift
//
//
//  Created by Alsey Coleman Miller on 3/25/26.
//

import Foundation
import CoreModel
import MapleStory

/// Guild entity (persisted in database)
public struct GuildEntity: Codable, Equatable, Hashable, Identifiable, Sendable {
    
    public typealias ID = UUID
    
    public let id: ID
    
    /// Guild name
    public let name: String
    
    /// Guild leader
    public var leaderID: Character.ID
    
    /// Maximum number of members
    public var capacity: Int
    
    /// Guild points (GP)
    public var points: UInt32
    
    /// Guild logo background
    public var logoBackground: UInt8
    
    /// Guild logo background color
    public var logoBackgroundColor: UInt8
    
    /// Guild logo
    public var logo: UInt8
    
    /// Guild logo color
    public var logoColor: UInt8
    
    /// Guild notice/bulletin
    public var notice: String?
    
    public init(
        id: ID = UUID(),
        name: String,
        leaderID: Character.ID,
        capacity: Int = 30,
        points: UInt32 = 0,
        logoBackground: UInt8 = 0,
        logoBackgroundColor: UInt8 = 0,
        logo: UInt8 = 0,
        logoColor: UInt8 = 0,
        notice: String? = nil
    ) {
        self.id = id
        self.name = name
        self.leaderID = leaderID
        self.capacity = capacity
        self.points = points
        self.logoBackground = logoBackground
        self.logoBackgroundColor = logoBackgroundColor
        self.logo = logo
        self.logoColor = logoColor
        self.notice = notice
    }
}