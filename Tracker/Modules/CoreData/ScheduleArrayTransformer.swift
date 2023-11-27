//
//  DaysValueTransformer.swift
//  Tracker
//
//  Created by Алишер Дадаметов on 20.11.2023.
//

import Foundation

@objc(DaysValueTransformer)
final class ScheduleArrayTransformer: ValueTransformer {
    override class func transformedValueClass() -> AnyClass {
        return NSData.self
    }

    override class func allowsReverseTransformation() -> Bool {
        return true
    }

    override func transformedValue(_ value: Any?) -> Any? {
        guard let days = value as? [Schedule] else { return nil }
        return try? JSONEncoder().encode(days)
    }

    override func reverseTransformedValue(_ value: Any?) -> Any? {
        guard let data = value as? NSData else { return nil }
        return try? JSONDecoder().decode([Schedule].self, from: data as Data)
    }
    
    static func register() {
        ValueTransformer.setValueTransformer(
            ScheduleArrayTransformer(),
            forName: NSValueTransformerName(rawValue: String(describing: ScheduleArrayTransformer.self))
        )
    }
}


