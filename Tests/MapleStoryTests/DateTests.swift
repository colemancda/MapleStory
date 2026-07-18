//
//  DateTests.swift
//
//  Tests for MapleStory date value types.
//

import Foundation
import XCTest
@testable import MapleStory

final class DateTests: XCTestCase {

    func testDateConstants() {
        XCTAssertEqual(Date.mapleGlobalRelease.timeIntervalSince1970, 1_115_769_600.0)
        XCTAssertEqual(Date.mapleGlobalRelease.description, "2005-05-11 00:00:00 +0000")
    }

    func testBirthdayValid() {
        let birthday = Birthday(rawValue: 20050511)
        XCTAssertNotNil(birthday)
        XCTAssertEqual(birthday?.rawValue, 20050511)
        XCTAssertEqual(birthday, .mapleStoryGlobal)
        XCTAssertEqual(Birthday.mapleStoryGlobal.timeIntervalSince1970, 1115769600.0)
        XCTAssertEqual(Birthday.mapleStoryGlobal.description, "2005-05-11 00:00:00 +0000")
        XCTAssertEqual(Birthday.mapleStoryGlobal.debugDescription, "2005-05-11 00:00:00 +0000")
    }

    func testBirthdayInvalid() {
        // An out-of-range month/day cannot form a valid date
        XCTAssertNil(Birthday(rawValue: 99999999))
        XCTAssertNil(Birthday(rawValue: 0))
    }

    func testBirthdayFromDate() {
        let birthday = Birthday(date: .mapleGlobalRelease)
        XCTAssertEqual(birthday.rawValue, 20050511)
        XCTAssertEqual(birthday.date, .mapleGlobalRelease)
    }

    func testBirthdayTimeInterval() {
        let birthday = Birthday(timeIntervalSince1970: 0)
        XCTAssertEqual(birthday.rawValue, 19700101)
        XCTAssertEqual(birthday.date, Date(timeIntervalSince1970: 0))
    }

    func testBirthdayCodableRoundTrip() throws {
        let birthday = Birthday.mapleStoryGlobal
        let data = try JSONEncoder().encode(birthday)
        let decoded = try JSONDecoder().decode(Birthday.self, from: data)
        XCTAssertEqual(decoded, birthday)
    }

    func testKoreanDateConstants() {
        XCTAssertEqual(KoreanDate.default.rawValue, 150842304000000000)
        XCTAssertEqual(KoreanDate.zero.rawValue, 94354848000000000)
        XCTAssertEqual(KoreanDate.permanent.rawValue, 150841440000000000)
    }

    func testKoreanDateLiteralAndInit() {
        let date: KoreanDate = 12345
        XCTAssertEqual(date.rawValue, 12345)
        XCTAssertEqual(KoreanDate(rawValue: 42).rawValue, 42)
    }

    func testMapleStoryDateProtocolExtensions() {
        // default init() uses current date
        let now = Birthday()
        XCTAssertGreaterThan(now.rawValue, 19700101)

        // init(_ date:)
        let birthday = Birthday(Date.mapleGlobalRelease)
        XCTAssertEqual(birthday.rawValue, 20050511)

        // Date(_ mapleDate:)
        let date = Date(Birthday.mapleStoryGlobal)
        XCTAssertEqual(date, .mapleGlobalRelease)

        // description(with:)
        let described = Birthday.mapleStoryGlobal.description(with: nil)
        XCTAssertFalse(described.isEmpty)
    }

    func testKoreanDateFromTimeInterval() {
        // Conversion should produce the offset for the epoch (time = 0)
        let date = KoreanDate(timeIntervalSince1970: 0)
        XCTAssertEqual(date.rawValue, 116444592000000000)
    }
}
