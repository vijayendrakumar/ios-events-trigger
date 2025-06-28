//
//  RecordedEvent.swift
//  IOSEventTrigger
//
//  Created by Vijayendra Kumar Madda on 28/06/25.
//

struct RecordedEvent: Codable {
    let timestamp: String
    let eventType: String
    let eventDetails: [String: AnyCodable]
}

struct AnyCodable: Codable {
    let value: Any
    
    init(_ value: Any) {
        self.value = value
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let string = try? container.decode(String.self) {
            self.value = string
        } else if let int = try? container.decode(Int.self) {
            self.value = int
        } else if let bool = try? container.decode(Bool.self) {
            self.value = bool
        } else if let double = try? container.decode(Double.self) {
            self.value = double
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unsupported type")
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch value {
        case let string as String:
            try container.encode(string)
        case let number as Int:
            try container.encode(number)
        case let bool as Bool:
            try container.encode(bool)
        case let double as Double:
            try container.encode(double)
        default:
            throw EncodingError.invalidValue(value, EncodingError.Context(codingPath: [], debugDescription: "Unsupported type"))
        }
    }
}
