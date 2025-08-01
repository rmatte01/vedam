//
//  vedamUITests.swift
//  vedamUITests
//
//  Created by Ravinder Matte on 7/27/25.
//

import XCTest

final class vedamUITests: XCTestCase {

    @MainActor
    func testAppFlow() throws {
        let app = XCUIApplication()
        app.launch()

        // Select 2 minutes
        app.buttons["2 minutes"].tap()
        
        // Check if timer view is displayed
        XCTAssert(app.staticTexts["Meditation"].exists)
        XCTAssert(app.staticTexts["02:00"].exists)
        
        // Start and pause the timer
        app.buttons["Start"].tap()
        XCTAssert(app.buttons["Pause"].exists)
        app.buttons["Pause"].tap()
        XCTAssert(app.buttons["Start"].exists)
        
        // Stop the meditation
        app.buttons["Stop"].tap()
        
        // Check if back to selection view
        XCTAssert(app.staticTexts["Select your meditation time"].exists)
    }
}