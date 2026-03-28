//
//  Movement+Position.swift
//

import Foundation

public extension Array where Element == Movement {

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
                break
            }
        }
        return (currentX, currentY)
    }
}
