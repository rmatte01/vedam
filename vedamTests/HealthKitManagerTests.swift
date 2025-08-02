//
//  HealthKitManagerTests.swift
//  vedamTests
//
//  Created by Ravinder Matte on 8/02/25.
//

import XCTest
import HealthKit
@testable import vedam

class HealthKitManagerTests: XCTestCase {
    
    var healthKitManager: HealthKitManager!
    
    override func setUp() {
        super.setUp()
        healthKitManager = HealthKitManager()
    }
    
    override func tearDown() {
        healthKitManager = nil
        super.tearDown()
    }
    
    func testRequestAuthorization() {
        let expectation = self.expectation(description: "Request HealthKit Authorization")
        
        healthKitManager.requestAuthorization { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
    
    func testSaveMeditation() {
        let expectation = self.expectation(description: "Save Meditation to HealthKit")
        
        healthKitManager.saveMeditation(minutes: 5) { success, error in
            XCTAssertTrue(success)
            XCTAssertNil(error)
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
    }
}
