//
//  MapleRoundTrip.swift
//
//  Shared helpers for MapleStory encoder/decoder round-trip tests.
//

import Foundation
import XCTest
@testable import MapleStory

/// Encode a value with the MapleStory encoder then decode it back and assert equality.
func XCTAssertMapleRoundTrip<T>(
    _ value: T,
    file: StaticString = #file,
    line: UInt = #line
) where T: Equatable, T: Codable {
    do {
        let encoder = MapleStoryEncoder()
        let decoder = MapleStoryDecoder()
        let data = try encoder.encode(value)
        let decoded = try decoder.decode(T.self, from: data)
        XCTAssertEqual(decoded, value, "MapleStory round-trip mismatch", file: file, line: line)
    } catch {
        XCTFail("MapleStory round-trip threw: \(error)", file: file, line: line)
    }
}

/// Encode a value with Foundation JSON then decode it back and assert equality.
func XCTAssertJSONRoundTrip<T>(
    _ value: T,
    file: StaticString = #file,
    line: UInt = #line
) where T: Equatable, T: Codable {
    do {
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        let data = try encoder.encode(value)
        let decoded = try decoder.decode(T.self, from: data)
        XCTAssertEqual(decoded, value, "JSON round-trip mismatch", file: file, line: line)
    } catch {
        XCTFail("JSON round-trip threw: \(error)", file: file, line: line)
    }
}
