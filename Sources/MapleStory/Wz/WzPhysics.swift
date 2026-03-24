//
//  WzPhysics.swift
//
//
//  Created by Alsey Coleman Miller on 3/23/26.
//

import Foundation

/// Global physics constants parsed from `Map.wz/Physics.img.xml`.
public struct WzPhysics: Equatable, Sendable {

    public let walkForce: Double
    public let walkSpeed: Double
    public let walkDrag: Double
    public let slipForce: Double
    public let slipSpeed: Double
    public let floatDrag1: Double
    public let floatDrag2: Double
    public let floatCoefficient: Double
    public let swimForce: Double
    public let swimSpeed: Double
    public let flyForce: Double
    public let flySpeed: Double
    public let gravityAcc: Double
    public let fallSpeed: Double
    public let jumpSpeed: Double
    public let maxFriction: Double
    public let minFriction: Double
    public let swimSpeedDec: Double

    /// Standard GMS v82 physics constants.
    public static let `default` = WzPhysics(
        walkForce:        140000.0,
        walkSpeed:        125.0,
        walkDrag:         80000.0,
        slipForce:        60000.0,
        slipSpeed:        120.0,
        floatDrag1:       100000.0,
        floatDrag2:       10000.0,
        floatCoefficient: 0.01,
        swimForce:        120000.0,
        swimSpeed:        140.0,
        flyForce:         120000.0,
        flySpeed:         200.0,
        gravityAcc:       2000.0,
        fallSpeed:        670.0,
        jumpSpeed:        555.0,
        maxFriction:      2.0,
        minFriction:      0.05,
        swimSpeedDec:     0.9
    )
}

// MARK: - Parsing

public extension WzPhysics {

    init(node: WzNode) {
        func d(_ key: String, default def: Double = 0) -> Double {
            node[key]?.doubleValue ?? def
        }
        walkForce        = d("walkForce")
        walkSpeed        = d("walkSpeed")
        walkDrag         = d("walkDrag")
        slipForce        = d("slipForce")
        slipSpeed        = d("slipSpeed")
        floatDrag1       = d("floatDrag1")
        floatDrag2       = d("floatDrag2")
        floatCoefficient = d("floatCoefficient")
        swimForce        = d("swimForce")
        swimSpeed        = d("swimSpeed")
        flyForce         = d("flyForce")
        flySpeed         = d("flySpeed")
        gravityAcc       = d("gravityAcc")
        fallSpeed        = d("fallSpeed")
        jumpSpeed        = d("jumpSpeed")
        maxFriction      = d("maxFriction")
        minFriction      = d("minFriction")
        swimSpeedDec     = d("swimSpeedDec")
    }

    init(contentsOf url: URL) throws {
        let node = try WzXMLParser().parse(contentsOf: url)
        self.init(node: node)
    }
}
