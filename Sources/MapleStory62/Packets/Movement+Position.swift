//
//  Movement+Position.swift
//
//
//  Created by Alsey Coleman Miller on 3/24/26.
//

import Foundation

/// Helper extension to extract final position from movement array
public extension Array where Element == Movement {

    /// Extract final position from movement sequence
    var finalPosition: (x: Int16, y: Int16)? {
        var currentX: Int16 = 0
        var currentY: Int16 = 0

        for movement in self {
            switch movement {
            case .absolute(let abs):
                currentX = Int16(abs.xpos)
                currentY = Int16(abs.ypos)
            case .relative(let rel):
                currentX = currentX + Int16(rel.xmod)
                currentY = currentY + Int16(rel.ymod)
            case .teleport(let tele):
                currentX = Int16(tele.xpos)
                currentY = Int16(tele.ypos)
            case .chair(let chair):
                currentX = Int16(chair.xpos)
                currentY = Int16(chair.ypos)
            case .jumpDown(let jump):
                currentX = Int16(jump.xpos)
                currentY = Int16(jump.ypos)
            case .changeEquipment:
                break // No position change
            }
        }

        return (currentX, currentY)
    }
}
