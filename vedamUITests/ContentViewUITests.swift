//
//  ContentViewUITests.swift
//  vedamUITests
//
//  Created by Ravinder Matte on 8/02/25.
//

import XCTest

class ContentViewUITests: XCTestCase {

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testMeditationFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // Select 2 minutes meditation
        app.buttons["2 min"].tap()
        
        // Start the meditation
        app.buttons["Start"].tap()
        
        // Wait for 2 seconds
        sleep(2)
        
        // Stop the meditation
        app.buttons["Stop"].tap()
        
        // Check if we are back on the main screen
        XCTAssertTrue(app.buttons["2 min"].exists)
    }
}
