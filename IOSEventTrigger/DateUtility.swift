//
//  DateUtility.swift
//  IOSEventTrigger
//
//  Created by Vijayendra Kumar Madda on 28/06/25.
//

import UIKit

class DateUtility {
    
    static func getFormattedDate() -> String {
        let timeStamp = Int(Date().timeIntervalSince1970 * 1000)
        let date = Date(timeIntervalSince1970: TimeInterval(timeStamp) / 1000)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss:ms"
        formatter.timeZone = TimeZone.current
        return formatter.string(from: date)
    }
    
}
