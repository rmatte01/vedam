//
//  MeditationTests.swift
//  vedamTests
//
//  Created by Ravinder Matte on 8/02/25.
//

import XCTest
@testable import vedam

class MeditationTests: XCTestCase {
    
    func testMeditationInitialization() {
        let date = Date()
        let meditation = Meditation(date: date, duration: 10)
        
        XCTAssertNotNil(meditation.id)
        XCTAssertEqual(meditation.date, date)
        XCTAssertEqual(meditation.duration, 10)
    }
    
    func testMeditationEquatable() {
        let date = Date()
        let meditation1 = Meditation(date: date, duration: 10)
        let meditation2 = Meditation(date: date, duration: 10)
        
        XCTAssertEqual(meditation1, meditation2)
    }
    
    func testMeditationCodable() {
        let date = Date()
        let meditation = Meditation(date: date, duration: 15)
        
        let encoder = JSONEncoder()
        let decoder = JSONDecoder()
        
        do {
            let data = try encoder.encode(meditation)
            let decodedMeditation = try decoder.decode(Meditation.self, from: data)
            
            XCTAssertEqual(meditation, decodedMeditation)
        } catch {
            XCTFail("Encoding or decoding failed with error: \(error)")
        }
    }
}
