//
//  EventRecorder.swift
//  IOSEventTrigger
//
//  Created by Vijayendra Kumar Madda on 28/06/25.
//

import Foundation
import XCTest

class EventRecorder {
    private let app: XCUIApplication
    private var events: [RecordedEvent] = []
    private var eventTypesToRecord: Set<String> = []
    private let fileManager: FileManager
    private let dateFormatter: ISO8601DateFormatter
    
    // Custom direction enum to replace XCUIElementQuery.Direction
    enum SwipeDirection: String, Codable {
        case up, down, left, right
    }
    
    init(app: XCUIApplication, eventTypes: Set<String> = ["tap", "swipe", "keyboard", "system"]) {
        self.app = app
        self.eventTypesToRecord = eventTypes
        self.fileManager = FileManager.default
        self.dateFormatter = ISO8601DateFormatter()
    }
    
    // Start recording events
    func startRecording() {
        setupSystemEventObservers()
        setupTouchTracking()
        setupKeyboardTracking()
    }
    
    // Stop recording and save to file
    func stopRecording(toFile fileName: String) {
        do {
            let jsonData = try JSONEncoder().encode(events)
            if let documentsDir = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first {
                print("documentsDir@@@@@@: \(documentsDir)")
                let fileURL = documentsDir.appendingPathComponent("\(fileName).json")
                try jsonData.write(to: fileURL)
            }
        } catch {
            print("Error saving events: \(error)")
        }
    }
    
    // Configure which event types to record
    func setEventTypesToRecord(_ types: Set<String>) {
        self.eventTypesToRecord = types
    }
    
    private func setupSystemEventObservers() {
        NotificationCenter.default.addObserver(
            forName: UIApplication.willEnterForegroundNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.recordEvent(type: "system", details: ["event": "app_will_enter_foreground"])
        }
        
        NotificationCenter.default.addObserver(
            forName: UIApplication.didBecomeActiveNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            self?.recordEvent(type: "system", details: ["event": "app_did_become_active"])
        }
        
        NotificationCenter.default.addObserver(
            forName: UIDevice.orientationDidChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] _ in
            let orientation = UIDevice.current.orientation
            let orientationString: String
            switch orientation {
            case .portrait:
                orientationString = "portrait"
            case .landscapeLeft, .landscapeRight:
                orientationString = "landscape"
            default:
                orientationString = "unknown"
            }
            self?.recordEvent(type: "system", details: ["event": "orientation_change", "orientation": orientationString])
        }
    }
    
    private func setupTouchTracking() {
        let window = app.windows.firstMatch
        window.tapOverride = { [weak self] point in
            self?.recordEvent(type: "tap", details: [
                "x": point.x,
                "y": point.y,
                "element": window.identifier.isEmpty ? "window" : window.identifier
            ])
        }
        
        window.swipeOverride = { [weak self] direction, point in
            self?.recordEvent(type: "swipe", details: [
                "direction": direction.rawValue,
                "x": point.x,
                "y": point.y,
                "element": window.identifier.isEmpty ? "window" : window.identifier
            ])
        }
    }
    
    private func setupKeyboardTracking() {
        
    }
    
    func recordEvent(type: String, details: [String: Any]) {
        guard eventTypesToRecord.contains(type) else { return }
        
        let event = RecordedEvent(
            timestamp: dateFormatter.string(from: Date()),
            eventType: type,
            eventDetails: details.mapValues { AnyCodable($0) }
        )
        events.append(event)
    }
}
