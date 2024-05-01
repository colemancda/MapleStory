//
//  MapleStoryTests.swift
//
//
//  Created by Alsey Coleman Miller on 12/14/22.
//

import Foundation
import XCTest
@testable import MapleStory
@testable import MapleStoryServer

final class MapleStoryTests: XCTestCase {
    
    func testJob() {
        
        XCTAssertEqual(Job.beginner.type, .beginner)
        
        XCTAssertEqual(Job.warrior.type, .warrior)
        XCTAssertEqual(Job.fighter.type, .warrior)
        XCTAssertEqual(Job.crusader.type, .warrior)
        XCTAssertEqual(Job.darkknight.type, .warrior)
        
        XCTAssertEqual(Job.magician.type, .magician)
        XCTAssertEqual(Job.fpWizard.type, .magician)
        XCTAssertEqual(Job.fpMage.type, .magician)
        XCTAssertEqual(Job.priest.type, .magician)
        XCTAssertEqual(Job.bishop.type, .magician)
        
        XCTAssertEqual(Job.bowman.type, .bowman)
        XCTAssertEqual(Job.hunter.type, .bowman)
        XCTAssertEqual(Job.sniper.type, .bowman)
        XCTAssertEqual(Job.marksman.type, .bowman)
        
        XCTAssertEqual(Job.thief.type, .thief)
        XCTAssertEqual(Job.assassin.type, .thief)
        XCTAssertEqual(Job.bandit.type, .thief)
        XCTAssertEqual(Job.shadower.type, .thief)
        
        XCTAssertEqual(Job.pirate.type, .pirate)
        XCTAssertEqual(Job.brawler.type, .pirate)
        XCTAssertEqual(Job.buccaneer.type, .pirate)
        XCTAssertEqual(Job.gunslinger.type, .pirate)
        XCTAssertEqual(Job.outlaw.type, .pirate)
        XCTAssertEqual(Job.corsair.type, .pirate)
        
        XCTAssertEqual(Job.gm.type, .gm)
        XCTAssertEqual(Job.supergm.type, .gm)
    }
    
    func testWorldName() {
        
        XCTAssertEqual(World.Name.scania.rawValue, "Scania")
        XCTAssertEqual(World.Name.scania.index, 0)
        XCTAssertEqual(World.Name(index: 0), .scania)
        
        XCTAssertNil(World.Name(index: 20))
        
        for (index, value) in World.Name.allCases.enumerated() {
            let index = UInt8(index)
            XCTAssertEqual(value.index, index)
            XCTAssertEqual(World.Name(index: index), value)
        }
    }
    
    func testUsername() {
        
        XCTAssertNil(Username(rawValue: ""))
        XCTAssertNil(Username(rawValue: "coleman 1"))
        XCTAssertNil(Username(rawValue: "coleman "))
        XCTAssertNil(Username(rawValue: " coleman"))
        XCTAssertNil(Username(rawValue: "coleman\n"))
        
        XCTAssertNotNil(Username(rawValue: "a"))
        XCTAssertNotNil(Username(rawValue: "abc"))
        XCTAssertNotNil(Username(rawValue: "abc125"))
        XCTAssertNotNil(Username(rawValue: "colemancda"))
        XCTAssertNotNil(Username(rawValue: "test1234"))
    }
    
    func testEmail() {
        
        XCTAssertNil(Email(rawValue: ""))
        XCTAssertNil(Email(rawValue: "coleman@"))
        XCTAssertNil(Email(rawValue: "coleman@fakedomain.xyz1"))
        XCTAssertNil(Email(rawValue: "coleman@gmail.com "))
        
        XCTAssertNotNil(Email(rawValue: "alseycmiller@gmail.com"))
        XCTAssertNotNil(Email(rawValue: "colemancda@icloud.com"))
        XCTAssertNotNil(Email(rawValue: "steve@apple.com"))
    }
    
    func testPassword() throws {
        
        let values = [
            "test1234",
            "pepe",
            "abc",
            "Testtest1234"
        ]
        
        for string in values {
            guard let password = Password(rawValue: string) else {
                XCTFail()
                return
            }
            let hash = try password.hash()
            let isValid = try password.validate(hash: hash)
            XCTAssert(isValid)
        }
    }
}
