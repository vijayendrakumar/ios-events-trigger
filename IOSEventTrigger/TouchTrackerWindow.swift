//
//  TouchTrackerWindow.swift
//  IOSEventTrigger
//
//  Created by Vijayendra Kumar Madda on 28/06/25.
//

import UIKit

class TouchTrackerWindow: UIWindow {
    
    override func sendEvent(_ event: UIEvent) {
        super.sendEvent(event)

        guard let touches = event.allTouches else { return }
        var textLog = TextLog()

        for touch in touches where touch.phase == .ended {
            let location = touch.location(in: self)
            print("Touch at: \(location)")
            textLog.write("**********User Touched location:************** \(location)")
        }
    }
    
}
