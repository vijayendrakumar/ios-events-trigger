//
//  IOSEventTriggerUITests.swift
//  IOSEventTriggerUITests
//
//  Created by Vijayendra Kumar Madda on 25/06/25.
//

import XCTest
import Foundation

class IOSEventTriggerUITests: XCTestCase {
    let app = XCUIApplication()
    
    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app.launch()
    }
    
    func testEventRecording() {
        let recorder = EventRecorder(app: app, eventTypes: ["tap", "swipe", "keyboard", "system"])
        recorder.startRecording()
        
        
        // Simulate user interactions
        let button = app.buttons["identifier_action_button"]
        button.tap()
        if button.exists {
            recorder.recordEvent(type: "tap", details: [
                "element": button.identifier.isEmpty ? "button" : button.identifier
            ])
        }
        
        let element = app.scrollViews.firstMatch
        if element.exists {
            element.swipeLeft()
            recorder.recordEvent(type: "swipe", details: [
                "element": element.identifier.isEmpty ? "unnamed scrollView" : element.identifier,
                "direction": "left"
            ])
        }
        
        // Simulate keyboard input
        let textField = app.textFields["identifier_input_textField"]
        if textField.exists {
            textField.tap()
            textField.typeText("test input")
            recorder.recordEvent(type: "keyboard", details: [
                "input": "test input",
                "element": textField.identifier.isEmpty ? "textField" : textField.identifier
            ])
        }
        
        // Wait for events to be captured
        sleep(2)
        
        // Save recorded events
        recorder.stopRecording(toFile: "test_events")
    }
    
}

extension XCUIElement {
    typealias TapHandler = (CGPoint) -> Void
    typealias SwipeHandler = (EventRecorder.SwipeDirection, CGPoint) -> Void
    
    var tapOverride: TapHandler? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.tapHandler) as? TapHandler }
        set { objc_setAssociatedObject(self, &AssociatedKeys.tapHandler, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    var swipeOverride: SwipeHandler? {
        get { objc_getAssociatedObject(self, &AssociatedKeys.swipeHandler) as? SwipeHandler }
        set { objc_setAssociatedObject(self, &AssociatedKeys.swipeHandler, newValue, .OBJC_ASSOCIATION_RETAIN) }
    }
    
    private struct AssociatedKeys {
        static var tapHandler: UInt8 = 0
        static var swipeHandler: UInt8 = 1
    }
}
